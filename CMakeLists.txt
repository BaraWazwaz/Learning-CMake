cmake_minimum_required(VERSION "3.19.2")

set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")

project(MyProject)
set(CMAKE_CXX_STANDARD 20)
file(GLOB_RECURSE MY_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
add_executable(MyProject ${MY_SOURCES})
target_include_directories(MyProject PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include/)
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_link_options(MyProject PRIVATE "-static-libgcc" "-static-libstdc++" "-static")
endif()
