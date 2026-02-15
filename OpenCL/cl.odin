package opencl

when ODIN_OS == .Windows {
    foreign import opencl "OpenCL.lib"
} else {
    foreign import opencl "system:OpenCL"
}

platform_id   :: distinct rawptr
device_id     :: distinct rawptr
ctx           :: distinct rawptr // NOTE: Avoid conflict with odin context
command_queue :: distinct rawptr
mem           :: distinct rawptr
program       :: distinct rawptr
kernel        :: distinct rawptr
event         :: distinct rawptr
sampler       :: distinct rawptr

image_format :: struct {
    image_channel_order:     u32,
    image_channel_data_type: u32,
}

image_desc :: struct {
    image_type:        u32,
    image_width:       uint,
    image_height:      uint,
    image_depth:       uint,
    image_array_size:  uint,
    image_row_pitch:   uint,
    image_slice_pitch: uint,
    num_mip_levels:    u32,
    num_samples:       u32,
    mem_object:        mem,
}

buffer_region :: struct {
    origin: uint,
    size:   uint,
}

NAME_VERSION_MAX_NAME_SIZE :: 64

name_version :: struct {
    version: u32,
    name: [NAME_VERSION_MAX_NAME_SIZE]u8,
}

@(default_calling_convention="system", link_prefix="cl")
foreign opencl {
    // Platform API
    GetPlatformIDs  :: proc(num_entries: u32, platforms: [^]platform_id, num_platforms: ^u32) -> i32 ---
    GetPlatformInfo :: proc(platform: platform_id, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Device APIs
    GetDeviceIDs                 :: proc(platform: platform_id, device_type: u64, num_entries: u32, devices: [^]device_id, num_devices: ^u32) -> i32 ---
    GetDeviceInfo                :: proc(device: device_id, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    CreateSubDevices             :: proc(in_device: device_id, properties: [^]int, num_devices: u32, out_devices: [^]device_id, num_devices_ret: ^u32) -> i32 ---
    RetainDevice                 :: proc(device: device_id) -> i32 ---
    ReleaseDevice                :: proc(device: device_id) -> i32 ---
    SetDefaultDeviceCommandQueue :: proc(ctx: ctx, device: device_id, command_queue: command_queue) -> i32 ---
    GetDeviceAndHostTimer        :: proc(device: device_id, device_timestamp: ^u64, host_timestamp: ^u64) -> i32 ---
    GetHostTimer                 :: proc(device: device_id, host_timestamp: ^u64) -> i32 ---

    // Context APIs
    CreateContext                :: proc(properties: [^]int, num_devices: u32, devices: [^]device_id, pfn_notify: proc(errinfo: cstring, private_info: rawptr, cb: uint, user_data: rawptr), user_data: rawptr, errcode_ret: ^i32) -> ctx ---
    CreateContextFromType        :: proc(properties: [^]int, device_type: u64, pfn_notify: proc(errinfo: cstring, private_info: rawptr, cb: uint, user_data: rawptr), user_data: rawptr, errcode_ret: ^i32) -> ctx ---
    RetainContext                :: proc(ctx: ctx) -> i32 ---
    ReleaseContext               :: proc(ctx: ctx) -> i32 ---
    GetContextInfo               :: proc(ctx: ctx, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    SetContextDestructorCallback :: proc(ctx: ctx, pfn_notify: proc(ctx: ctx, user_data: rawptr), user_data: rawptr) -> i32 ---

    // Command Queue APIs
    CreateCommandQueueWithProperties :: proc(ctx: ctx, device: device_id, properties: [^]u64, errcode_ret: ^i32) -> command_queue ---
    RetainCommandQueue               :: proc(command_queue: command_queue) -> i32 ---
    ReleaseCommandQueue              :: proc(command_queue: command_queue) -> i32 ---
    GetCommandQueueInfo              :: proc(command_queue: command_queue, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Memory Object APIs
    CreateBuffer                   :: proc(ctx: ctx, flags: u64, size: uint, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    CreateSubBuffer                :: proc(buffer: mem, flags: u64, buffer_create_type: u32, buffer_create_info: rawptr, errcode_ret: ^i32) -> mem ---
    CreateImage                    :: proc(ctx: ctx, flags: u64, #by_ptr image_format: image_format, #by_ptr image_desc: image_desc, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    CreatePipe                     :: proc(ctx: ctx, flags: u32, pipe_packet_size: u32, pipe_max_packets: u32, properties: [^]int, errcode_ret: ^i32) -> mem ---
    CreateBufferWithProperties     :: proc(ctx: ctx, properties: [^]u64, flags: u64, size: uint, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    CreateImageWithProperties      :: proc(ctx: ctx, properties: [^]u64, flags: u64, #by_ptr image_format: image_format, #by_ptr image_desc: image_desc, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    RetainMemObject                :: proc(memobj: mem) -> i32 ---
    ReleaseMemObject               :: proc(memobj: mem) -> i32 ---
    GetSupportedImageFormats       :: proc(ctx: ctx, flags: u64, image_type: u32, num_entries: u32, image_formats: [^]image_format, num_image_formats: ^u32) -> i32 ---
    GetMemObjectInfo               :: proc(memobj: mem, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetImageInfo                   :: proc(image: mem, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetPipeInfo                    :: proc(pipe: mem, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    SetMemObjectDestructorCallback :: proc(memobj: mem, pfn_notify: proc(memobj: mem, user_data: rawptr), user_data: rawptr) -> i32 ---

    // SVM Allocation APIs
    SVMAlloc :: proc(ctx: ctx, flags: u64, size: uint, alignment: u32) -> rawptr ---
    SVMFree  :: proc(ctx: ctx, svm_pointer: rawptr) ---

    // Sampler APIs
    CreateSamplerWithProperties :: proc(ctx: ctx, sampler_properties: [^]u64, errcode_ret: ^i32) -> sampler ---
    RetainSampler               :: proc(sampler: sampler) -> i32 ---
    ReleaseSampler              :: proc(sampler: sampler) -> i32 ---
    GetSamplerInfo              :: proc(sampler: sampler, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Program Object APIs
    CreateProgramWithSource          :: proc(ctx: ctx, count: u32, strings: [^]cstring, lengths: [^]uint, errcode_ret: ^i32) -> program ---
    CreateProgramWithBinary          :: proc(ctx: ctx, num_devices: u32, device_list: [^]device_id, lengths: [^]uint, binaries: [^]cstring, binary_status: ^i32, errcode_ret: ^i32) -> program ---
    CreateProgramWithBuiltInKernels  :: proc(ctx: ctx, num_devices: u32, device_list: [^]device_id, kernel_names: cstring, errcode_ret: ^i32) -> program ---
    CreateProgramWithIL              :: proc(ctx: ctx, il: rawptr, length: uint, errcode_ret: ^i32) -> program ---
    RetainProgram                    :: proc(prog: program) -> i32 ---
    ReleaseProgram                   :: proc(prog: program) -> i32 ---
    BuildProgram                     :: proc(prog: program, num_devices: u32, device_list: [^]device_id, options: cstring, pfn_notify: proc(prog: program, user_data: rawptr), user_data: rawptr) -> i32 ---
    CompileProgram                   :: proc(prog: program, num_devices: u32, device_list: [^]device_id, options: cstring, num_input_headers: u32, input_headers: [^]program, header_include_names: [^]cstring, pfn_notify: proc(prog: program, user_data: rawptr), user_data: rawptr) -> i32 ---
    LinkProgram                      :: proc(ctx: ctx, num_devices: u32, device_list: [^]device_id, options: cstring, num_input_programs: u32, input_programs: [^]program, pfn_notify: proc(prog: program, user_data: rawptr), user_data: rawptr, errcode_ret: ^i32) -> program ---
    SetProgramReleaseCallback        :: proc(prog: program, pfn_notify: proc(prog: program, user_data: rawptr), user_data: rawptr) -> i32 ---
    SetProgramSpecializationConstant :: proc(prog: program, spec_id: u32, spec_size: uint, spec_value: rawptr) -> i32 ---
    UnloadPlatformCompiler           :: proc(platform: platform_id) -> i32 ---
    GetProgramInfo                   :: proc(prog: program, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetProgramBuildInfo              :: proc(prog: program, device: device_id, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Kernel Object APIs
    CreateKernel           :: proc(prog: program, kernel_name: cstring , errcode_ret: ^i32) -> kernel ---
    CreateKernelsInProgram :: proc(prog: program, num_kernels: u32, kernels: [^]kernel, num_kernels_ret: ^u32) -> i32 ---
    CloneKernel            :: proc(source_kernel: kernel, errcode_ret: ^i32) -> kernel ---
    RetainKernel           :: proc(kernel: kernel) -> i32 ---
    ReleaseKernel          :: proc(kernel: kernel) -> i32 ---
    SetKernelArg           :: proc(kernel: kernel, arg_index: u32, arg_size: uint, arg_value: rawptr) -> i32 ---
    SetKernelArgSVMPointer :: proc(kernel: kernel, arg_index: u32, arg_value: rawptr) -> i32 ---
    SetKernelExecInfo      :: proc(kernel: kernel, param_name: u32, param_value_size: uint, param_value: rawptr ) -> i32 ---
    GetKernelInfo          :: proc(kernel: kernel, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetKernelArgInfo       :: proc(kernel: kernel, arg_indx: u32, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetKernelWorkGroupInfo :: proc(kernel: kernel, device: device_id, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    GetKernelSubGroupInfo  :: proc(kernel: kernel, device: device_id, param_name: u32, input_value_size: uint, input_value: rawptr, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Event Object APIs
    WaitForEvents      :: proc(num_events: u32, event_list: [^]event) -> i32 ---
    GetEventInfo       :: proc(event: event, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---
    CreateUserEvent    :: proc(ctx: ctx, errcode_ret: ^i32) -> event ---
    RetainEvent        :: proc(event: event) -> i32 ---
    ReleaseEvent       :: proc(event: event) -> i32 ---
    SetUserEventStatus :: proc(event: event, execution_status: i32) -> i32 ---
    SetEventCallback   :: proc(event: event, command_exec_callback_type: i32, pfn_notify: proc(event: event, event_command_status: i32, user_data: rawptr), user_data: rawptr) -> i32 ---

    // Profiling APIs 
    GetEventProfilingInfo :: proc(event: event, param_name: u32, param_value_size: uint, param_value: rawptr, param_value_size_ret: ^uint) -> i32 ---

    // Flush and Finish APIs 
    Flush  :: proc(command_queue: command_queue) -> i32 ---
    Finish :: proc(command_queue: command_queue) -> i32 ---

    // Enqueued Commands APIs
    EnqueueReadBuffer          :: proc(command_queue: command_queue, buffer: mem, blocking_read: u32, offset: uint, size: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueReadBufferRect      :: proc(command_queue: command_queue, buffer: mem, blocking_read: u32, buffer_origin: [^]uint, host_origin: [^]uint, region: [^]uint, buffer_row_pitch: uint, buffer_slice_pitch: uint, host_row_pitch: uint, host_slice_pitch: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueWriteBuffer         :: proc(command_queue: command_queue, buffer: mem, blocking_write: u32, offset: uint, size: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueWriteBufferRect     :: proc(command_queue: command_queue, buffer: mem, blocking_write: u32, buffer_origin: [^]uint, host_origin: [^]uint, region: [^]uint, buffer_row_pitch: uint, buffer_slice_pitch: uint, host_row_pitch: uint, host_slice_pitch: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueFillBuffer          :: proc(command_queue: command_queue, buffer: mem, pattern: rawptr, pattern_size: uint, offset: uint, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueCopyBuffer          :: proc(command_queue: command_queue, src_buffer: mem, dst_buffer: mem, src_offset: uint, dst_offset: uint, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueCopyBufferRect      :: proc(command_queue: command_queue, src_buffer: mem, dst_buffer: mem, src_origin: [^]uint, dst_origin: [^]uint, region: [^]uint, src_row_pitch: uint, src_slice_pitch: uint, dst_row_pitch: uint, dst_slice_pitch: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueReadImage           :: proc(command_queue: command_queue, image: mem, blocking_read: u32, origin: [^]uint, region: [^]uint, row_pitch: uint, slice_pitch: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueWriteImage          :: proc(command_queue: command_queue, image: mem, blocking_write: u32, origin: [^]uint, region: [^]uint, input_row_pitch: uint, input_slice_pitch: uint, ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueFillImage           :: proc(command_queue: command_queue, image: mem, fill_color: rawptr, origin: [^]uint, region: [^]uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueCopyImage           :: proc(command_queue: command_queue, src_image: mem, dst_image: mem, src_origin: [^]uint, dst_origin: [^]uint, region: [^]uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueCopyImageToBuffer   :: proc(command_queue: command_queue, src_image: mem, dst_buffer: mem, src_origin: [^]uint, region: [^]uint, dst_offset: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueCopyBufferToImage   :: proc(command_queue: command_queue, src_buffer: mem, dst_image: mem, src_offset: uint, dst_origin: [^]uint, region: [^]uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueMapBuffer           :: proc(command_queue: command_queue, buffer: mem, blocking_map: u32, map_flags: u64, offset: uint, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event, errcode_ret: ^i32) -> rawptr ---
    EnqueueMapImage            :: proc(command_queue: command_queue, image: mem, blocking_map: u32, map_flags: u64, origin: [^]uint, region: [^]uint, image_row_pitch: ^uint, image_slice_pitch: ^uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event, errcode_ret: ^i32) -> rawptr ---
    EnqueueUnmapMemObject      :: proc(command_queue: command_queue, memobj: mem, mapped_ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueMigrateMemObjects   :: proc(command_queue: command_queue, num_mem_objects: u32, mem_objects: [^]mem, flags: u64, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueNDRangeKernel       :: proc(command_queue: command_queue, kernel: kernel, work_dim: u32, global_work_offset: [^]uint, global_work_size: [^]uint, local_work_size: [^]uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueNativeKernel        :: proc(command_queue: command_queue, user_func: proc(ptr: rawptr), args: rawptr, cb_args: uint, num_mem_objects: u32, mem_list: [^]mem, args_mem_loc: ^rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueMarkerWithWaitList  :: proc(command_queue: command_queue, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueBarrierWithWaitList :: proc(command_queue: command_queue, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMFree             :: proc(command_queue: command_queue, num_svm_pointers: u32, svm_pointers: [^]rawptr, pfn_free_func: proc(queue: command_queue, num_svm_pointers: u32, svm_pointers: [^]rawptr, user_data: rawptr), user_data: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMMemcpy           :: proc(command_queue: command_queue, blocking_copy: u32, dst_ptr: rawptr, src_ptr: rawptr, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMMemFill          :: proc(command_queue: command_queue, svm_ptr: rawptr, pattern: rawptr, pattern_size: uint, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMMap              :: proc(command_queue: command_queue, blocking_map: u32, flags: u64, svm_ptr: rawptr, size: uint, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMUnmap            :: proc(command_queue: command_queue, svm_ptr: rawptr, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
    EnqueueSVMMigrateMem       :: proc(command_queue: command_queue, num_svm_pointers: u32, svm_pointers: [^]rawptr, sizes: [^]uint, flags: u64, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---

    // Extension function access
    GetExtensionFunctionAddressForPlatform :: proc(platform: platform_id, func_name: cstring ) -> rawptr ---

    // Deprecated OpenCL 1.0 APIs
    SetCommandQueueProperty :: proc(command_queue: command_queue, properties: u64, enable: u32, old_properties: ^u64) -> i32 ---

    // Deprecated OpenCL 1.1 APIs
    CreateImage2D               :: proc(ctx: ctx, flags: u64, #by_ptr image_format: image_format, image_width: uint, image_height: uint, image_row_pitch: uint, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    CreateImage3D               :: proc(ctx: ctx, flags: u64, #by_ptr image_format: image_format, image_width: uint, image_height: uint, image_depth: uint, image_row_pitch: uint, image_slice_pitch: uint, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    EnqueueMarker               :: proc(command_queue: command_queue, event: ^event) -> i32 ---
    EnqueueWaitForEvents        :: proc(command_queue: command_queue, num_events: u32, event_list: [^]event) -> i32 ---
    EnqueueBarrier              :: proc(command_queue: command_queue) -> i32 ---
    UnloadCompiler              :: proc() -> i32 ---
    GetExtensionFunctionAddress :: proc(func_name: cstring) -> rawptr ---

    // Deprecated OpenCL 2.0 APIs 
    CreateCommandQueue :: proc(ctx: ctx, device: device_id, properties: u64, errcode_ret: ^i32) -> command_queue ---
    CreateSampler      :: proc(ctx: ctx, normalized_coords: u32, addressing_mode: u32, filter_mode: u32, errcode_ret: ^i32) -> sampler ---
    EnqueueTask        :: proc(command_queue: command_queue, kernel: kernel, num_events_in_wait_list: u32, event_wait_list: [^]event, event: ^event) -> i32 ---
}

// Error Codes
SUCCESS                                        ::  0
DEVICE_NOT_FOUND                               :: -1
DEVICE_NOT_AVAILABLE                           :: -2
COMPILER_NOT_AVAILABLE                         :: -3
MEM_OBJECT_ALLOCATION_FAILURE                  :: -4
OUT_OF_RESOURCES                               :: -5
OUT_OF_HOST_MEMORY                             :: -6
PROFILING_INFO_NOT_AVAILABLE                   :: -7
MEM_COPY_OVERLAP                               :: -8
IMAGE_FORMAT_MISMATCH                          :: -9
IMAGE_FORMAT_NOT_SUPPORTED                     :: -10
BUILD_PROGRAM_FAILURE                          :: -11
MAP_FAILURE                                    :: -12
MISALIGNED_SUB_BUFFER_OFFSET                   :: -13
EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST      :: -14
COMPILE_PROGRAM_FAILURE                        :: -15
LINKER_NOT_AVAILABLE                           :: -16
LINK_PROGRAM_FAILURE                           :: -17
DEVICE_PARTITION_FAILED                        :: -18
KERNEL_ARG_INFO_NOT_AVAILABLE                  :: -19
INVALID_VALUE                                  :: -30
INVALID_DEVICE_TYPE                            :: -31
INVALID_PLATFORM                               :: -32
INVALID_DEVICE                                 :: -33
INVALID_CONTEXT                                :: -34
INVALID_QUEUE_PROPERTIES                       :: -35
INVALID_COMMAND_QUEUE                          :: -36
INVALID_HOST_PTR                               :: -37
INVALID_MEM_OBJECT                             :: -38
INVALID_IMAGE_FORMAT_DESCRIPTOR                :: -39
INVALID_IMAGE_SIZE                             :: -40
INVALID_SAMPLER                                :: -41
INVALID_BINARY                                 :: -42
INVALID_BUILD_OPTIONS                          :: -43
INVALID_PROGRAM                                :: -44
INVALID_PROGRAM_EXECUTABLE                     :: -45
INVALID_KERNEL_NAME                            :: -46
INVALID_KERNEL_DEFINITION                      :: -47
INVALID_KERNEL                                 :: -48
INVALID_ARG_INDEX                              :: -49
INVALID_ARG_VALUE                              :: -50
INVALID_ARG_SIZE                               :: -51
INVALID_KERNEL_ARGS                            :: -52
INVALID_WORK_DIMENSION                         :: -53
INVALID_WORK_GROUP_SIZE                        :: -54
INVALID_WORK_ITEM_SIZE                         :: -55
INVALID_GLOBAL_OFFSET                          :: -56
INVALID_EVENT_WAIT_LIST                        :: -57
INVALID_EVENT                                  :: -58
INVALID_OPERATION                              :: -59
INVALID_GL_OBJECT                              :: -60
INVALID_BUFFER_SIZE                            :: -61
INVALID_MIP_LEVEL                              :: -62
INVALID_GLOBAL_WORK_SIZE                       :: -63
INVALID_PROPERTY                               :: -64
INVALID_IMAGE_DESCRIPTOR                       :: -65
INVALID_COMPILER_OPTIONS                       :: -66
INVALID_LINKER_OPTIONS                         :: -67
INVALID_DEVICE_PARTITION_COUNT                 :: -68
INVALID_PIPE_SIZE                              :: -69
INVALID_DEVICE_QUEUE                           :: -70
INVALID_SPEC_ID                                :: -71
MAX_SIZE_RESTRICTION_EXCEEDED                  :: -72

// cl_bool
TRUE                                           :: 1
FALSE                                          :: 0
BLOCKING                                       :: TRUE
NON_BLOCKING                                   :: FALSE

// cl_platform_info
PLATFORM_PROFILE                               :: 0x0900
PLATFORM_VERSION                               :: 0x0901
PLATFORM_NAME                                  :: 0x0902
PLATFORM_VENDOR                                :: 0x0903
PLATFORM_EXTENSIONS                            :: 0x0904
PLATFORM_HOST_TIMER_RESOLUTION                 :: 0x0905
PLATFORM_NUMERIC_VERSION                       :: 0x0906
PLATFORM_EXTENSIONS_WITH_VERSION               :: 0x0907

// cl_device_type - bitfield
DEVICE_TYPE_DEFAULT                            :: 1 << 0
DEVICE_TYPE_CPU                                :: 1 << 1
DEVICE_TYPE_GPU                                :: 1 << 2
DEVICE_TYPE_ACCELERATOR                        :: 1 << 3
DEVICE_TYPE_CUSTOM                             :: 1 << 4
DEVICE_TYPE_ALL                                :: 0xFFFFFFFF

// cl_device_info 
DEVICE_TYPE                                    :: 0x1000
DEVICE_VENDOR_ID                               :: 0x1001
DEVICE_MAX_COMPUTE_UNITS                       :: 0x1002
DEVICE_MAX_WORK_ITEM_DIMENSIONS                :: 0x1003
DEVICE_MAX_WORK_GROUP_SIZE                     :: 0x1004
DEVICE_MAX_WORK_ITEM_SIZES                     :: 0x1005
DEVICE_PREFERRED_VECTOR_WIDTH_CHAR             :: 0x1006
DEVICE_PREFERRED_VECTOR_WIDTH_SHORT            :: 0x1007
DEVICE_PREFERRED_VECTOR_WIDTH_INT              :: 0x1008
DEVICE_PREFERRED_VECTOR_WIDTH_LONG             :: 0x1009
DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT            :: 0x100A
DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE           :: 0x100B
DEVICE_MAX_CLOCK_FREQUENCY                     :: 0x100C
DEVICE_ADDRESS_BITS                            :: 0x100D
DEVICE_MAX_READ_IMAGE_ARGS                     :: 0x100E
DEVICE_MAX_WRITE_IMAGE_ARGS                    :: 0x100F
DEVICE_MAX_MEM_ALLOC_SIZE                      :: 0x1010
DEVICE_IMAGE2D_MAX_WIDTH                       :: 0x1011
DEVICE_IMAGE2D_MAX_HEIGHT                      :: 0x1012
DEVICE_IMAGE3D_MAX_WIDTH                       :: 0x1013
DEVICE_IMAGE3D_MAX_HEIGHT                      :: 0x1014
DEVICE_IMAGE3D_MAX_DEPTH                       :: 0x1015
DEVICE_IMAGE_SUPPORT                           :: 0x1016
DEVICE_MAX_PARAMETER_SIZE                      :: 0x1017
DEVICE_MAX_SAMPLERS                            :: 0x1018
DEVICE_MEM_BASE_ADDR_ALIGN                     :: 0x1019
DEVICE_MIN_DATA_TYPE_ALIGN_SIZE                :: 0x101A
DEVICE_SINGLE_FP_CONFIG                        :: 0x101B
DEVICE_GLOBAL_MEM_CACHE_TYPE                   :: 0x101C
DEVICE_GLOBAL_MEM_CACHELINE_SIZE               :: 0x101D
DEVICE_GLOBAL_MEM_CACHE_SIZE                   :: 0x101E
DEVICE_GLOBAL_MEM_SIZE                         :: 0x101F
DEVICE_MAX_CONSTANT_BUFFER_SIZE                :: 0x1020
DEVICE_MAX_CONSTANT_ARGS                       :: 0x1021
DEVICE_LOCAL_MEM_TYPE                          :: 0x1022
DEVICE_LOCAL_MEM_SIZE                          :: 0x1023
DEVICE_ERROR_CORRECTION_SUPPORT                :: 0x1024
DEVICE_PROFILING_TIMER_RESOLUTION              :: 0x1025
DEVICE_ENDIAN_LITTLE                           :: 0x1026
DEVICE_AVAILABLE                               :: 0x1027
DEVICE_COMPILER_AVAILABLE                      :: 0x1028
DEVICE_EXECUTION_CAPABILITIES                  :: 0x1029
DEVICE_QUEUE_PROPERTIES                        :: 0x102A
DEVICE_QUEUE_ON_HOST_PROPERTIES                :: 0x102A
DEVICE_NAME                                    :: 0x102B
DEVICE_VENDOR                                  :: 0x102C
DRIVER_VERSION                                 :: 0x102D
DEVICE_PROFILE                                 :: 0x102E
DEVICE_VERSION                                 :: 0x102F
DEVICE_EXTENSIONS                              :: 0x1030
DEVICE_PLATFORM                                :: 0x1031
DEVICE_DOUBLE_FP_CONFIG                        :: 0x1032
DEVICE_PREFERRED_VECTOR_WIDTH_HALF             :: 0x1034
DEVICE_HOST_UNIFIED_MEMORY                     :: 0x1035
DEVICE_NATIVE_VECTOR_WIDTH_CHAR                :: 0x1036
DEVICE_NATIVE_VECTOR_WIDTH_SHORT               :: 0x1037
DEVICE_NATIVE_VECTOR_WIDTH_INT                 :: 0x1038
DEVICE_NATIVE_VECTOR_WIDTH_LONG                :: 0x1039
DEVICE_NATIVE_VECTOR_WIDTH_FLOAT               :: 0x103A
DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE              :: 0x103B
DEVICE_NATIVE_VECTOR_WIDTH_HALF                :: 0x103C
DEVICE_OPENCL_C_VERSION                        :: 0x103D
DEVICE_LINKER_AVAILABLE                        :: 0x103E
DEVICE_BUILT_IN_KERNELS                        :: 0x103F
DEVICE_IMAGE_MAX_BUFFER_SIZE                   :: 0x1040
DEVICE_IMAGE_MAX_ARRAY_SIZE                    :: 0x1041
DEVICE_PARENT_DEVICE                           :: 0x1042
DEVICE_PARTITION_MAX_SUB_DEVICES               :: 0x1043
DEVICE_PARTITION_PROPERTIES                    :: 0x1044
DEVICE_PARTITION_AFFINITY_DOMAIN               :: 0x1045
DEVICE_PARTITION_TYPE                          :: 0x1046
DEVICE_REFERENCE_COUNT                         :: 0x1047
DEVICE_PREFERRED_INTEROP_USER_SYNC             :: 0x1048
DEVICE_PRINTF_BUFFER_SIZE                      :: 0x1049
DEVICE_IMAGE_PITCH_ALIGNMENT                   :: 0x104A
DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT            :: 0x104B
DEVICE_MAX_READ_WRITE_IMAGE_ARGS               :: 0x104C
DEVICE_MAX_GLOBAL_VARIABLE_SIZE                :: 0x104D
DEVICE_QUEUE_ON_DEVICE_PROPERTIES              :: 0x104E
DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE          :: 0x104F
DEVICE_QUEUE_ON_DEVICE_MAX_SIZE                :: 0x1050
DEVICE_MAX_ON_DEVICE_QUEUES                    :: 0x1051
DEVICE_MAX_ON_DEVICE_EVENTS                    :: 0x1052
DEVICE_SVM_CAPABILITIES                        :: 0x1053
DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE    :: 0x1054
DEVICE_MAX_PIPE_ARGS                           :: 0x1055
DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS            :: 0x1056
DEVICE_PIPE_MAX_PACKET_SIZE                    :: 0x1057
DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT     :: 0x1058
DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT       :: 0x1059
DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT        :: 0x105A
DEVICE_IL_VERSION                              :: 0x105B
DEVICE_MAX_NUM_SUB_GROUPS                      :: 0x105C
DEVICE_SUB_GROUP_INDEPENDENT_FORWARD_PROGRESS  :: 0x105D
DEVICE_NUMERIC_VERSION                         :: 0x105E
DEVICE_EXTENSIONS_WITH_VERSION                 :: 0x1060
DEVICE_ILS_WITH_VERSION                        :: 0x1061
DEVICE_BUILT_IN_KERNELS_WITH_VERSION           :: 0x1062
DEVICE_ATOMIC_MEMORY_CAPABILITIES              :: 0x1063
DEVICE_ATOMIC_FENCE_CAPABILITIES               :: 0x1064
DEVICE_NON_UNIFORM_WORK_GROUP_SUPPORT          :: 0x1065
DEVICE_OPENCL_C_ALL_VERSIONS                   :: 0x1066
DEVICE_PREFERRED_WORK_GROUP_SIZE_MULTIPLE      :: 0x1067
DEVICE_WORK_GROUP_COLLECTIVE_FUNCTIONS_SUPPORT :: 0x1068
DEVICE_GENERIC_ADDRESS_SPACE_SUPPORT           :: 0x1069
DEVICE_OPENCL_C_FEATURES                       :: 0x106F
DEVICE_DEVICE_ENQUEUE_CAPABILITIES             :: 0x1070
DEVICE_PIPE_SUPPORT                            :: 0x1071
DEVICE_LATEST_CONFORMANCE_VERSION_PASSED       :: 0x1072

// cl_device_fp_config - bitfield
FP_DENORM                                      :: 1 << 0
FP_INF_NAN                                     :: 1 << 1
FP_ROUND_TO_NEAREST                            :: 1 << 2
FP_ROUND_TO_ZERO                               :: 1 << 3
FP_ROUND_TO_INF                                :: 1 << 4
FP_FMA                                         :: 1 << 5
FP_SOFT_FLOAT                                  :: 1 << 6
FP_CORRECTLY_ROUNDED_DIVIDE_SQRT               :: 1 << 7

// cl_device_mem_cache_type
NONE                                           :: 0x0
READ_ONLY_CACHE                                :: 0x1
READ_WRITE_CACHE                               :: 0x2

// cl_device_local_mem_type
LOCAL                                          :: 0x1
GLOBAL                                         :: 0x2

// cl_device_exec_capabilities - bitfield
EXEC_KERNEL                                    :: 1 << 0
EXEC_NATIVE_KERNEL                             :: 1 << 1

// cl_command_queue_properties - bitfield
QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE            :: 1 << 0
QUEUE_PROFILING_ENABLE                         :: 1 << 1
QUEUE_ON_DEVICE                                :: 1 << 2
QUEUE_ON_DEVICE_DEFAULT                        :: 1 << 3

// cl_context_info
CONTEXT_REFERENCE_COUNT                        :: 0x1080
CONTEXT_DEVICES                                :: 0x1081
CONTEXT_PROPERTIES                             :: 0x1082
CONTEXT_NUM_DEVICES                            :: 0x1083

// cl_context_properties
CONTEXT_PLATFORM                               :: 0x1084
CONTEXT_INTEROP_USER_SYNC                      :: 0x1085

// cl_device_partition_property
DEVICE_PARTITION_EQUALLY                       :: 0x1086
DEVICE_PARTITION_BY_COUNTS                     :: 0x1087
DEVICE_PARTITION_BY_COUNTS_LIST_END            :: 0x0
DEVICE_PARTITION_BY_AFFINITY_DOMAIN            :: 0x1088

// cl_device_affinity_domain
DEVICE_AFFINITY_DOMAIN_NUMA                    :: 1 << 0
DEVICE_AFFINITY_DOMAIN_L4_CACHE                :: 1 << 1
DEVICE_AFFINITY_DOMAIN_L3_CACHE                :: 1 << 2
DEVICE_AFFINITY_DOMAIN_L2_CACHE                :: 1 << 3
DEVICE_AFFINITY_DOMAIN_L1_CACHE                :: 1 << 4
DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE      :: 1 << 5

// cl_device_svm_capabilities
DEVICE_SVM_COARSE_GRAIN_BUFFER                 :: 1 << 0
DEVICE_SVM_FINE_GRAIN_BUFFER                   :: 1 << 1
DEVICE_SVM_FINE_GRAIN_SYSTEM                   :: 1 << 2
DEVICE_SVM_ATOMICS                             :: 1 << 3

// cl_command_queue_info
QUEUE_CONTEXT                                  :: 0x1090
QUEUE_DEVICE                                   :: 0x1091
QUEUE_REFERENCE_COUNT                          :: 0x1092
QUEUE_PROPERTIES                               :: 0x1093
QUEUE_SIZE                                     :: 0x1094
QUEUE_DEVICE_DEFAULT                           :: 0x1095
QUEUE_PROPERTIES_ARRAY                         :: 0x1098

// cl_mem_flags and cl_svm_mem_flags - bitfield
MEM_READ_WRITE                                 :: 1 << 0
MEM_WRITE_ONLY                                 :: 1 << 1
MEM_READ_ONLY                                  :: 1 << 2
MEM_USE_HOST_PTR                               :: 1 << 3
MEM_ALLOC_HOST_PTR                             :: 1 << 4
MEM_COPY_HOST_PTR                              :: 1 << 5
// reserved                                    :: 1 << 6   
MEM_HOST_WRITE_ONLY                            :: 1 << 7
MEM_HOST_READ_ONLY                             :: 1 << 8
MEM_HOST_NO_ACCESS                             :: 1 << 9
MEM_SVM_FINE_GRAIN_BUFFER                      :: 1 << 10
MEM_SVM_ATOMICS                                :: 1 << 11
MEM_KERNEL_READ_AND_WRITE                      :: 1 << 12

// cl_mem_migration_flags - bitfield
MIGRATE_MEM_OBJECT_HOST                        :: 1 << 0
MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED           :: 1 << 1

// cl_channel_order
R                                              :: 0x10B0
A                                              :: 0x10B1
RG                                             :: 0x10B2
RA                                             :: 0x10B3
RGB                                            :: 0x10B4
RGBA                                           :: 0x10B5
BGRA                                           :: 0x10B6
ARGB                                           :: 0x10B7
INTENSITY                                      :: 0x10B8
LUMINANCE                                      :: 0x10B9
Rx                                             :: 0x10BA
RGx                                            :: 0x10BB
RGBx                                           :: 0x10BC
DEPTH                                          :: 0x10BD
sRGB                                           :: 0x10BF
sRGBx                                          :: 0x10C0
sRGBA                                          :: 0x10C1
sBGRA                                          :: 0x10C2
ABGR                                           :: 0x10C3

// cl_channel_type
SNORM_INT8                                     :: 0x10D0
SNORM_INT16                                    :: 0x10D1
UNORM_INT8                                     :: 0x10D2
UNORM_INT16                                    :: 0x10D3
UNORM_SHORT_565                                :: 0x10D4
UNORM_SHORT_555                                :: 0x10D5
UNORM_INT_101010                               :: 0x10D6
SIGNED_INT8                                    :: 0x10D7
SIGNED_INT16                                   :: 0x10D8
SIGNED_INT32                                   :: 0x10D9
UNSIGNED_INT8                                  :: 0x10DA
UNSIGNED_INT16                                 :: 0x10DB
UNSIGNED_INT32                                 :: 0x10DC
HALF_FLOAT                                     :: 0x10DD
FLOAT                                          :: 0x10DE
UNORM_INT_101010_2                             :: 0x10E0

// cl_mem_object_type
MEM_OBJECT_BUFFER                              :: 0x10F0
MEM_OBJECT_IMAGE2D                             :: 0x10F1
MEM_OBJECT_IMAGE3D                             :: 0x10F2
MEM_OBJECT_IMAGE2D_ARRAY                       :: 0x10F3
MEM_OBJECT_IMAGE1D                             :: 0x10F4
MEM_OBJECT_IMAGE1D_ARRAY                       :: 0x10F5
MEM_OBJECT_IMAGE1D_BUFFER                      :: 0x10F6
MEM_OBJECT_PIPE                                :: 0x10F7

// cl_mem_info
MEM_TYPE                                       :: 0x1100
MEM_FLAGS                                      :: 0x1101
MEM_SIZE                                       :: 0x1102
MEM_HOST_PTR                                   :: 0x1103
MEM_MAP_COUNT                                  :: 0x1104
MEM_REFERENCE_COUNT                            :: 0x1105
MEM_CONTEXT                                    :: 0x1106
MEM_ASSOCIATED_MEMOBJECT                       :: 0x1107
MEM_OFFSET                                     :: 0x1108
MEM_USES_SVM_POINTER                           :: 0x1109
MEM_PROPERTIES                                 :: 0x110A

// cl_image_info
IMAGE_FORMAT                                   :: 0x1110
IMAGE_ELEMENT_SIZE                             :: 0x1111
IMAGE_ROW_PITCH                                :: 0x1112
IMAGE_SLICE_PITCH                              :: 0x1113
IMAGE_WIDTH                                    :: 0x1114
IMAGE_HEIGHT                                   :: 0x1115
IMAGE_DEPTH                                    :: 0x1116
IMAGE_ARRAY_SIZE                               :: 0x1117
IMAGE_BUFFER                                   :: 0x1118
IMAGE_NUM_MIP_LEVELS                           :: 0x1119
IMAGE_NUM_SAMPLES                              :: 0x111A

// cl_pipe_info
PIPE_PACKET_SIZE                               :: 0x1120
PIPE_MAX_PACKETS                               :: 0x1121
PIPE_PROPERTIES                                :: 0x1122

// cl_addressing_mode
ADDRESS_NONE                                   :: 0x1130
ADDRESS_CLAMP_TO_EDGE                          :: 0x1131
ADDRESS_CLAMP                                  :: 0x1132
ADDRESS_REPEAT                                 :: 0x1133
ADDRESS_MIRRORED_REPEAT                        :: 0x1134

// cl_filter_mode
FILTER_NEAREST                                 :: 0x1140
FILTER_LINEAR                                  :: 0x1141

// cl_sampler_info
SAMPLER_REFERENCE_COUNT                        :: 0x1150
SAMPLER_CONTEXT                                :: 0x1151
SAMPLER_NORMALIZED_COORDS                      :: 0x1152
SAMPLER_ADDRESSING_MODE                        :: 0x1153
SAMPLER_FILTER_MODE                            :: 0x1154
SAMPLER_MIP_FILTER_MODE                        :: 0x1155
SAMPLER_LOD_MIN                                :: 0x1156
SAMPLER_LOD_MAX                                :: 0x1157
SAMPLER_PROPERTIES                             :: 0x1158

// cl_map_flags - bitfield
MAP_READ                                       :: 1 << 0
MAP_WRITE                                      :: 1 << 1
MAP_WRITE_INVALIDATE_REGION                    :: 1 << 2

// cl_program_info
PROGRAM_REFERENCE_COUNT                        :: 0x1160
PROGRAM_CONTEXT                                :: 0x1161
PROGRAM_NUM_DEVICES                            :: 0x1162
PROGRAM_DEVICES                                :: 0x1163
PROGRAM_SOURCE                                 :: 0x1164
PROGRAM_BINARY_SIZES                           :: 0x1165
PROGRAM_BINARIES                               :: 0x1166
PROGRAM_NUM_KERNELS                            :: 0x1167
PROGRAM_KERNEL_NAMES                           :: 0x1168
PROGRAM_IL                                     :: 0x1169
PROGRAM_SCOPE_GLOBAL_CTORS_PRESENT             :: 0x116A
PROGRAM_SCOPE_GLOBAL_DTORS_PRESENT             :: 0x116B

// cl_program_build_info
PROGRAM_BUILD_STATUS                           :: 0x1181
PROGRAM_BUILD_OPTIONS                          :: 0x1182
PROGRAM_BUILD_LOG                              :: 0x1183
PROGRAM_BINARY_TYPE                            :: 0x1184
PROGRAM_BUILD_GLOBAL_VARIABLE_TOTAL_SIZE       :: 0x1185

// cl_program_binary_type
PROGRAM_BINARY_TYPE_NONE                       :: 0x0
PROGRAM_BINARY_TYPE_COMPILED_OBJECT            :: 0x1
PROGRAM_BINARY_TYPE_LIBRARY                    :: 0x2
PROGRAM_BINARY_TYPE_EXECUTABLE                 :: 0x4

// cl_build_status
BUILD_SUCCESS                                  ::  0
BUILD_NONE                                     :: -1
BUILD_ERROR                                    :: -2
BUILD_IN_PROGRESS                              :: -3

// cl_kernel_info
KERNEL_FUNCTION_NAME                           :: 0x1190
KERNEL_NUM_ARGS                                :: 0x1191
KERNEL_REFERENCE_COUNT                         :: 0x1192
KERNEL_CONTEXT                                 :: 0x1193
KERNEL_PROGRAM                                 :: 0x1194
KERNEL_ATTRIBUTES                              :: 0x1195

// cl_kernel_arg_info
KERNEL_ARG_ADDRESS_QUALIFIER                   :: 0x1196
KERNEL_ARG_ACCESS_QUALIFIER                    :: 0x1197
KERNEL_ARG_TYPE_NAME                           :: 0x1198
KERNEL_ARG_TYPE_QUALIFIER                      :: 0x1199
KERNEL_ARG_NAME                                :: 0x119A

// cl_kernel_arg_address_qualifier
KERNEL_ARG_ADDRESS_GLOBAL                      :: 0x119B
KERNEL_ARG_ADDRESS_LOCAL                       :: 0x119C
KERNEL_ARG_ADDRESS_CONSTANT                    :: 0x119D
KERNEL_ARG_ADDRESS_PRIVATE                     :: 0x119E

// cl_kernel_arg_access_qualifier
KERNEL_ARG_ACCESS_READ_ONLY                    :: 0x11A0
KERNEL_ARG_ACCESS_WRITE_ONLY                   :: 0x11A1
KERNEL_ARG_ACCESS_READ_WRITE                   :: 0x11A2
KERNEL_ARG_ACCESS_NONE                         :: 0x11A3

// cl_kernel_arg_type_qualifier
KERNEL_ARG_TYPE_NONE                           :: 0
KERNEL_ARG_TYPE_CONST                          :: 1 << 0
KERNEL_ARG_TYPE_RESTRICT                       :: 1 << 1
KERNEL_ARG_TYPE_VOLATILE                       :: 1 << 2
KERNEL_ARG_TYPE_PIPE                           :: 1 << 3

// cl_kernel_work_group_info
KERNEL_WORK_GROUP_SIZE                         :: 0x11B0
KERNEL_COMPILE_WORK_GROUP_SIZE                 :: 0x11B1
KERNEL_LOCAL_MEM_SIZE                          :: 0x11B2
KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE      :: 0x11B3
KERNEL_PRIVATE_MEM_SIZE                        :: 0x11B4
KERNEL_GLOBAL_WORK_SIZE                        :: 0x11B5

// cl_kernel_sub_group_info
KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE          :: 0x2033
KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE             :: 0x2034
KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT          :: 0x11B8
KERNEL_MAX_NUM_SUB_GROUPS                      :: 0x11B9
KERNEL_COMPILE_NUM_SUB_GROUPS                  :: 0x11BA

// cl_kernel_exec_info
KERNEL_EXEC_INFO_SVM_PTRS                      :: 0x11B6
KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM         :: 0x11B7

// cl_event_info
EVENT_COMMAND_QUEUE                            :: 0x11D0
EVENT_COMMAND_TYPE                             :: 0x11D1
EVENT_REFERENCE_COUNT                          :: 0x11D2
EVENT_COMMAND_EXECUTION_STATUS                 :: 0x11D3
EVENT_CONTEXT                                  :: 0x11D4

// cl_command_type
COMMAND_NDRANGE_KERNEL                         :: 0x11F0
COMMAND_TASK                                   :: 0x11F1
COMMAND_NATIVE_KERNEL                          :: 0x11F2
COMMAND_READ_BUFFER                            :: 0x11F3
COMMAND_WRITE_BUFFER                           :: 0x11F4
COMMAND_COPY_BUFFER                            :: 0x11F5
COMMAND_READ_IMAGE                             :: 0x11F6
COMMAND_WRITE_IMAGE                            :: 0x11F7
COMMAND_COPY_IMAGE                             :: 0x11F8
COMMAND_COPY_IMAGE_TO_BUFFER                   :: 0x11F9
COMMAND_COPY_BUFFER_TO_IMAGE                   :: 0x11FA
COMMAND_MAP_BUFFER                             :: 0x11FB
COMMAND_MAP_IMAGE                              :: 0x11FC
COMMAND_UNMAP_MEM_OBJECT                       :: 0x11FD
COMMAND_MARKER                                 :: 0x11FE
COMMAND_ACQUIRE_GL_OBJECTS                     :: 0x11FF
COMMAND_RELEASE_GL_OBJECTS                     :: 0x1200
COMMAND_READ_BUFFER_RECT                       :: 0x1201
COMMAND_WRITE_BUFFER_RECT                      :: 0x1202
COMMAND_COPY_BUFFER_RECT                       :: 0x1203
COMMAND_USER                                   :: 0x1204
COMMAND_BARRIER                                :: 0x1205
COMMAND_MIGRATE_MEM_OBJECTS                    :: 0x1206
COMMAND_FILL_BUFFER                            :: 0x1207
COMMAND_FILL_IMAGE                             :: 0x1208
COMMAND_SVM_FREE                               :: 0x1209
COMMAND_SVM_MEMCPY                             :: 0x120A
COMMAND_SVM_MEMFILL                            :: 0x120B
COMMAND_SVM_MAP                                :: 0x120C
COMMAND_SVM_UNMAP                              :: 0x120D
COMMAND_SVM_MIGRATE_MEM                        :: 0x120E

// command execution status
COMPLETE                                       :: 0x0
RUNNING                                        :: 0x1
SUBMITTED                                      :: 0x2
QUEUED                                         :: 0x3

// cl_buffer_create_type
BUFFER_CREATE_TYPE_REGION                      :: 0x1220

// cl_profiling_info
PROFILING_COMMAND_QUEUED                       :: 0x1280
PROFILING_COMMAND_SUBMIT                       :: 0x1281
PROFILING_COMMAND_START                        :: 0x1282
PROFILING_COMMAND_END                          :: 0x1283
PROFILING_COMMAND_COMPLETE                     :: 0x1284

// cl_device_atomic_capabilities - bitfield
DEVICE_ATOMIC_ORDER_RELAXED                    :: 1 << 0
DEVICE_ATOMIC_ORDER_ACQ_REL                    :: 1 << 1
DEVICE_ATOMIC_ORDER_SEQ_CST                    :: 1 << 2
DEVICE_ATOMIC_SCOPE_WORK_ITEM                  :: 1 << 3
DEVICE_ATOMIC_SCOPE_WORK_GROUP                 :: 1 << 4
DEVICE_ATOMIC_SCOPE_DEVICE                     :: 1 << 5
DEVICE_ATOMIC_SCOPE_ALL_DEVICES                :: 1 << 6

// cl_device_device_enqueue_capabilities - bitfield
DEVICE_QUEUE_SUPPORTED                         :: 1 << 0
DEVICE_QUEUE_REPLACEABLE_DEFAULT               :: 1 << 1

// cl_khronos_vendor_id
KHRONOS_VENDOR_ID_CODEPLAY                     :: 0x10004

// cl_version
VERSION_MAJOR_BITS                             :: 10
VERSION_MINOR_BITS                             :: 10
VERSION_PATCH_BITS                             :: 12

VERSION_MAJOR_MASK                             :: (1 << VERSION_MAJOR_BITS) - 1
VERSION_MINOR_MASK                             :: (1 << VERSION_MINOR_BITS) - 1
VERSION_PATCH_MASK                             :: (1 << VERSION_PATCH_BITS) - 1

version_major :: proc "contextless" (version: u32) -> u32 {
    return version >> (VERSION_MINOR_BITS + VERSION_PATCH_BITS)
}

version_minor :: proc "contextless" (version: u32) -> u32 {
    return (version >> VERSION_PATCH_BITS) & VERSION_MINOR_MASK
}

version_patch :: proc "contextless" (version: u32) -> u32 {
    return version & VERSION_PATCH_MASK
}

make_version :: proc "contextless" (major, minor, patch: u32) -> u32 {
    v := (major & VERSION_MAJOR_MASK) << (VERSION_MINOR_BITS + VERSION_PATCH_BITS)
    v |= (minor & VERSION_MINOR_MASK) << VERSION_PATCH_BITS
    v |= (patch & VERSION_PATCH_MASK)
    return v
}
