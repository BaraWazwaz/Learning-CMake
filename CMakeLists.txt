cmake_minimum_required(VERSION "3.19.2")

set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")

project("CMakeHelloWorld")
add_executable("CMakeHelloWorld" "main.cpp" "header.cpp" "header.hpp")
