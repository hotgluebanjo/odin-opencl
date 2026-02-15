package square

import "core:fmt"
import "core:os"

import cl "../../OpenCL"

program_source: cstring = `
float square(float x) {
    return x * x;
}

__kernel void square_kernel(__global float *src, __global float *dst, int n_samples) {
    int i = get_global_id(0);

    if (i >= n_samples) {
        return;
    }

    dst[i] = square(src[i]);
}
`

show_status :: proc(msg: string, status: i32) {
    fmt.eprintfln("%s: [%d]", msg, status);
}

main :: proc() {
    n_samples        := uint(50)
    local_work_size  := uint(256)
    global_work_size := (n_samples + local_work_size - 1) / local_work_size * local_work_size

    buf_src := make([]f32, global_work_size);
    buf_dst := make([]f32, global_work_size);
    defer delete(buf_src)
    defer delete(buf_dst)
    for i in 0..<n_samples {
        buf_src[i] = f32(i);
    }

    status: i32

    platform: cl.platform_id
    status = cl.GetPlatformIDs(1, &platform, nil)
    show_status("Get platform ID", status)

    device: cl.device_id
    status = cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_GPU, 1, &device, nil)
    show_status("Get device ID", status)

    ctx := cl.CreateContext(nil, 1, &device, nil, nil, &status)
    show_status("Create GPU context", status)
    defer cl.ReleaseContext(ctx)

    command_queue := cl.CreateCommandQueue(ctx, device, 0, &status)
    show_status("Create command queue", status)
    defer cl.ReleaseCommandQueue(command_queue)

    cl_buf_src := cl.CreateBuffer(ctx, cl.MEM_READ_ONLY, size_of(f32) * global_work_size, nil, &status)
    show_status("Create buffer src", status)
    cl_buf_dst := cl.CreateBuffer(ctx, cl.MEM_WRITE_ONLY, size_of(f32) * global_work_size, nil, &status)
    show_status("Create buffer dst", status)
    defer cl.ReleaseMemObject(cl_buf_src)
    defer cl.ReleaseMemObject(cl_buf_dst)

    program := cl.CreateProgramWithSource(ctx, 1, &program_source, nil, &status)
    show_status("Create program", status)
    defer cl.ReleaseProgram(program)
    status = cl.BuildProgram(program, 0, nil, nil, nil, nil)
    show_status("Build program", status)

    kernel := cl.CreateKernel(program, "square_kernel", &status)
    show_status("Create kernel", status)
    defer cl.ReleaseKernel(kernel)

    status = 0
    status |= cl.SetKernelArg(kernel, 0, size_of(cl.mem), cast(rawptr)&cl_buf_src)
    status |= cl.SetKernelArg(kernel, 1, size_of(cl.mem), cast(rawptr)&cl_buf_dst)
    status |= cl.SetKernelArg(kernel, 2, size_of(i32),    cast(rawptr)&n_samples)
    show_status("Set args", status)

    status = cl.EnqueueWriteBuffer(command_queue, cl_buf_src, cl.FALSE, 0, size_of(f32) * global_work_size, raw_data(buf_src), 0, nil, nil)
    show_status("Enqueue write buf", status)

    status = cl.EnqueueNDRangeKernel(command_queue, kernel, 1, nil, &global_work_size, &local_work_size, 0, nil, nil)
    show_status("Enqueue kernel", status)

    status = cl.EnqueueReadBuffer(command_queue, cl_buf_dst, cl.TRUE, 0, size_of(f32) * global_work_size, raw_data(buf_dst), 0, nil, nil)
    show_status("Enqueue read buf", status)

    for i in 0..<n_samples {
        fmt.println(buf_dst[i])
    }
}
