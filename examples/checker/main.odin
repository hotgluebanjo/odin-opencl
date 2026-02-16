// Simple type/build checker. Example usage:
//   odin run examples/checker -- examples/checker/errors.cl '-Werror -DSOME_EXAMPLE_DEFINE'
package checker

import "core:fmt"
import "core:os"
import "core:strings"

import cl "../../OpenCL"

error_msg :: proc(msg: string, status: i32) {
    fmt.eprintfln("%s: %s [%d]", msg, status_to_string(status), status)
}

main :: proc() {
    if len(os.args) < 2 {
        fmt.println("USAGE: checker [SOURCE FILE]")
        return
    }

    file := os.args[1]
    source, source_ok := os.read_entire_file(file)
    if !source_ok {
        fmt.eprintfln("Failed to read OpenCL program source '%s'", file)
        return
    }
    defer delete(source)
    program_source     := cstring(raw_data(source))
    program_source_len := uint(len(source))

    build_options: cstring = nil
    if len(os.args) > 2 {
        build_options = strings.clone_to_cstring(os.args[2])
    }
    defer delete(build_options)

    status: i32

    platform: cl.platform_id
    status = cl.GetPlatformIDs(1, &platform, nil)
    if status != cl.SUCCESS {
        error_msg("Failed to get platform ID", status)
        return
    }

    device: cl.device_id
    status = cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_GPU, 1, &device, nil)
    if status != cl.SUCCESS {
        error_msg("Failed to get device ID", status)
        return
    }

    ctx := cl.CreateContext(nil, 1, &device, nil, nil, &status)
    defer cl.ReleaseContext(ctx)
    if status != cl.SUCCESS {
        error_msg("Failed to create context", status)
        return
    }

    program := cl.CreateProgramWithSource(ctx, 1, &program_source, &program_source_len, &status)
    defer cl.ReleaseProgram(program)
    if status != cl.SUCCESS {
        error_msg("Failed to create program", status)
        return
    }

    status = cl.BuildProgram(program, 0, nil, build_options, nil, nil)
    if status == cl.BUILD_PROGRAM_FAILURE {
        log_size: uint
        cl.GetProgramBuildInfo(program, device, cl.PROGRAM_BUILD_LOG, 0, nil, &log_size)
        log := make([]u8, log_size)
        defer delete(log)
        cl.GetProgramBuildInfo(program, device, cl.PROGRAM_BUILD_LOG, log_size, raw_data(log), nil)
        fmt.eprintln(string(log))
        return
    } else if status != cl.SUCCESS {
        error_msg("Failed to build program", status)
        return
    }

    fmt.println("Successfully built program")
}

status_to_string :: proc(code: i32) -> string {
    switch (code) {
    case cl.SUCCESS:                                   return "SUCCESS"
    case cl.DEVICE_NOT_FOUND:                          return "DEVICE NOT FOUND"
    case cl.DEVICE_NOT_AVAILABLE:                      return "DEVICE NOT AVAILABLE"
    case cl.COMPILER_NOT_AVAILABLE:                    return "COMPILER NOT AVAILABLE"
    case cl.MEM_OBJECT_ALLOCATION_FAILURE:             return "MEM OBJECT ALLOCATION FAILURE"
    case cl.OUT_OF_RESOURCES:                          return "OUT OF RESOURCES"
    case cl.OUT_OF_HOST_MEMORY:                        return "OUT OF HOST MEMORY"
    case cl.PROFILING_INFO_NOT_AVAILABLE:              return "PROFILING INFO NOT AVAILABLE"
    case cl.MEM_COPY_OVERLAP:                          return "MEM COPY OVERLAP"
    case cl.IMAGE_FORMAT_MISMATCH:                     return "IMAGE FORMAT MISMATCH"
    case cl.IMAGE_FORMAT_NOT_SUPPORTED:                return "IMAGE FORMAT NOT SUPPORTED"
    case cl.BUILD_PROGRAM_FAILURE:                     return "BUILD PROGRAM FAILURE"
    case cl.MAP_FAILURE:                               return "MAP FAILURE"
    case cl.MISALIGNED_SUB_BUFFER_OFFSET:              return "MISALIGNED SUB BUFFER OFFSET"
    case cl.EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST: return "EXEC STATUS ERROR FOR EVENTS IN WAIT LIST"
    case cl.COMPILE_PROGRAM_FAILURE:                   return "COMPILE PROGRAM FAILURE"
    case cl.LINKER_NOT_AVAILABLE:                      return "LINKER NOT AVAILABLE"
    case cl.LINK_PROGRAM_FAILURE:                      return "LINK PROGRAM FAILURE"
    case cl.DEVICE_PARTITION_FAILED:                   return "DEVICE PARTITION FAILED"
    case cl.KERNEL_ARG_INFO_NOT_AVAILABLE:             return "KERNEL ARG INFO NOT AVAILABLE"
    case cl.INVALID_VALUE:                             return "INVALID VALUE"
    case cl.INVALID_DEVICE_TYPE:                       return "INVALID DEVICE TYPE"
    case cl.INVALID_PLATFORM:                          return "INVALID PLATFORM"
    case cl.INVALID_DEVICE:                            return "INVALID DEVICE"
    case cl.INVALID_CONTEXT:                           return "INVALID CONTEXT"
    case cl.INVALID_QUEUE_PROPERTIES:                  return "INVALID QUEUE PROPERTIES"
    case cl.INVALID_COMMAND_QUEUE:                     return "INVALID COMMAND QUEUE"
    case cl.INVALID_HOST_PTR:                          return "INVALID HOST PTR"
    case cl.INVALID_MEM_OBJECT:                        return "INVALID MEM OBJECT"
    case cl.INVALID_IMAGE_FORMAT_DESCRIPTOR:           return "INVALID IMAGE FORMAT DESCRIPTOR"
    case cl.INVALID_IMAGE_SIZE:                        return "INVALID IMAGE SIZE"
    case cl.INVALID_SAMPLER:                           return "INVALID SAMPLER"
    case cl.INVALID_BINARY:                            return "INVALID BINARY"
    case cl.INVALID_BUILD_OPTIONS:                     return "INVALID BUILD OPTIONS"
    case cl.INVALID_PROGRAM:                           return "INVALID PROGRAM"
    case cl.INVALID_PROGRAM_EXECUTABLE:                return "INVALID PROGRAM EXECUTABLE"
    case cl.INVALID_KERNEL_NAME:                       return "INVALID KERNEL NAME"
    case cl.INVALID_KERNEL_DEFINITION:                 return "INVALID KERNEL DEFINITION"
    case cl.INVALID_KERNEL:                            return "INVALID KERNEL"
    case cl.INVALID_ARG_INDEX:                         return "INVALID ARG INDEX"
    case cl.INVALID_ARG_VALUE:                         return "INVALID ARG VALUE"
    case cl.INVALID_ARG_SIZE:                          return "INVALID ARG SIZE"
    case cl.INVALID_KERNEL_ARGS:                       return "INVALID KERNEL ARGS"
    case cl.INVALID_WORK_DIMENSION:                    return "INVALID WORK DIMENSION"
    case cl.INVALID_WORK_GROUP_SIZE:                   return "INVALID WORK GROUP SIZE"
    case cl.INVALID_WORK_ITEM_SIZE:                    return "INVALID WORK ITEM SIZE"
    case cl.INVALID_GLOBAL_OFFSET:                     return "INVALID GLOBAL OFFSET"
    case cl.INVALID_EVENT_WAIT_LIST:                   return "INVALID EVENT WAIT LIST"
    case cl.INVALID_EVENT:                             return "INVALID EVENT"
    case cl.INVALID_OPERATION:                         return "INVALID OPERATION"
    case cl.INVALID_GL_OBJECT:                         return "INVALID GL OBJECT"
    case cl.INVALID_BUFFER_SIZE:                       return "INVALID BUFFER SIZE"
    case cl.INVALID_MIP_LEVEL:                         return "INVALID MIP LEVEL"
    case cl.INVALID_GLOBAL_WORK_SIZE:                  return "INVALID GLOBAL WORK SIZE"
    case cl.INVALID_PROPERTY:                          return "INVALID PROPERTY"
    case cl.INVALID_IMAGE_DESCRIPTOR:                  return "INVALID IMAGE DESCRIPTOR"
    case cl.INVALID_COMPILER_OPTIONS:                  return "INVALID COMPILER OPTIONS"
    case cl.INVALID_LINKER_OPTIONS:                    return "INVALID LINKER OPTIONS"
    case cl.INVALID_DEVICE_PARTITION_COUNT:            return "INVALID DEVICE PARTITION COUNT"
    case cl.INVALID_PIPE_SIZE:                         return "INVALID PIPE SIZE"
    case cl.INVALID_DEVICE_QUEUE:                      return "INVALID DEVICE QUEUE"
    case cl.INVALID_SPEC_ID:                           return "INVALID SPEC ID"
    case cl.MAX_SIZE_RESTRICTION_EXCEEDED:             return "MAX SIZE RESTRICTION EXCEEDED"
    case:                                              return "UNKNOWN"
    }
}
