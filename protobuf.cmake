# The current FindProtobuf.cmake shipped with CMake doesn't allow you to specify
# where to look for Protobuf.  Since Conan already knows where Protobuf lives, all we really
# need is a copy of the protobuf_generate_cpp function.

# TODO - Windows compatibility
set(PROTOBUF_PROTOC_EXECUTABLE ${CONAN_BIN_DIRS_PROTOBUF}/protoc)

function(PROTOBUF_GENERATE_CPP SRCS HDRS)
    if(NOT ARGN)
        message(SEND_ERROR "Error: PROTOBUF_GENERATE_CPP() called without any proto files")
        return()
    endif()

    if(PROTOBUF_GENERATE_CPP_APPEND_PATH)
        # Create an include path for each file specified
        foreach(FIL ${ARGN})
            get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
            get_filename_component(ABS_PATH ${ABS_FIL} PATH)
            list(FIND _protobuf_include_path ${ABS_PATH} _contains_already)
            if(${_contains_already} EQUAL -1)
                list(APPEND _protobuf_include_path -I ${ABS_PATH})
            endif()
        endforeach()
    else()
        set(_protobuf_include_path -I ${CMAKE_CURRENT_SOURCE_DIR})
    endif()

    if(DEFINED PROTOBUF_IMPORT_DIRS AND NOT DEFINED Protobuf_IMPORT_DIRS)
        set(Protobuf_IMPORT_DIRS "${PROTOBUF_IMPORT_DIRS}")
    endif()

    if(DEFINED Protobuf_IMPORT_DIRS)
        foreach(DIR ${Protobuf_IMPORT_DIRS})
            get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
            list(FIND _protobuf_include_path ${ABS_PATH} _contains_already)
            if(${_contains_already} EQUAL -1)
                list(APPEND _protobuf_include_path -I ${ABS_PATH})
            endif()
        endforeach()
    endif()

    set(${SRCS})
    set(${HDRS})
    foreach(FIL ${ARGN})
        get_filename_component(ABS_FIL ${FIL} ABSOLUTE)
        get_filename_component(FIL_WE ${FIL} NAME_WE)

        list(APPEND ${SRCS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc")
        list(APPEND ${HDRS} "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h")

        add_custom_command(
                OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.cc"
                "${CMAKE_CURRENT_BINARY_DIR}/${FIL_WE}.pb.h"
                COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE}
                ARGS --cpp_out  ${CMAKE_CURRENT_BINARY_DIR} ${_protobuf_include_path} ${ABS_FIL}
                DEPENDS ${ABS_FIL} ${PROTOBUF_PROTOC_EXECUTABLE}
                COMMENT "Running C++ protocol buffer compiler on ${FIL}"
                VERBATIM )
    endforeach()

    set_source_files_properties(${${SRCS}} ${${HDRS}} PROPERTIES GENERATED TRUE)
    set(${SRCS} ${${SRCS}} PARENT_SCOPE)
    set(${HDRS} ${${HDRS}} PARENT_SCOPE)
endfunction()