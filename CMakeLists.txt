cmake_minimum_required(VERSION "3.19.2")

set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")

project(MyProject)
set(CMAKE_CXX_STANDARD 20)

option(BUILD_EXECUTABLE "Build the main application executable" ON)

include(FetchContent)
set(FMT_TEST OFF CACHE INTERNAL "")
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        11.0.2
)
FetchContent_MakeAvailable(fmt)

file(GLOB LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/lib/*.cpp")

add_library(MyLibrary ${LIB_SOURCES})

target_include_directories(MyLibrary PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/")
target_link_libraries(MyLibrary PUBLIC fmt::fmt)
target_compile_definitions(MyLibrary PUBLIC RESOURCES_PATH=\"./resources/\") #"

if(BUILD_EXECUTABLE)
    file(GLOB EXE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

    add_executable(MyProject ${EXE_SOURCES})
    target_link_libraries(MyProject PRIVATE MyLibrary)

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_link_options(MyProject PRIVATE "-static-libgcc" "-static-libstdc++" "-static")
    endif()
endif()
