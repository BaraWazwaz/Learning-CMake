#!/bin/env bash

# 1. CMake Set up
step_001() {
    nano ./CMakeLists.txt
    # write its content
}

# 2. Build Set up
step_002() {
    mkdir ./build
    cd ./build
    cmake -G "MinGW Makefiles" ..
}

# 3. Build Projects' Executables
step_003() {
    cmake --build .
}

# 4. Run Executables
step_004() {
    ./CMakeHelloWorld.exe
    ./SecondProject.exe
}

echo "Open this file to view the scripts, this script file does not run anything by itself"
