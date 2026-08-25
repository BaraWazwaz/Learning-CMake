cmake_minimum_required(VERSION "3.19.2")

set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")

project(MyProject)
set(CMAKE_CXX_STANDARD 20)
add_executable(MyProject src/main.cpp src/header.cpp)
target_include_directories(MyProject PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include/)
