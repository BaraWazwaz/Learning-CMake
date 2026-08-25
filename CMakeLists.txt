cmake_minimum_required(VERSION "3.19.2")

# ==========================================
# 1. TOOLCHAIN & COMPILER CONFIGURATION
# ==========================================
if(WIN32)
    set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
    set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")
endif()

project(MyProject)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set default fallback configuration for single-config generators (like MinGW Makefiles)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Choose the build type: Debug or Release" FORCE)
endif()

# ==========================================
# 2. USER SWITCHES & OPTIONS
# ==========================================
option(BUILD_EXECUTABLE "Build the main application executable" ON)

# ==========================================
# 3. AUTOMATED DEPENDENCY MANAGEMENT
# ==========================================
include(FetchContent)
set(FMT_TEST OFF CACHE INTERNAL "")
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        11.0.2
)
FetchContent_MakeAvailable(fmt)

# ==========================================
# 4. INTERPROCEDURAL OPTIMIZATION (PROD ONLY)
# ==========================================
include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported LANGUAGES CXX)

if(ipo_supported)
    # Default it to OFF globally to keep local dev compile times fast
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
endif()

# ==========================================
# 5. INDEPENDENT LIBRARY TARGET (From ./lib/)
# ==========================================
file(GLOB LIB_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/lib/*.cpp")
add_library(MyLibrary ${LIB_SOURCES})

# Target Requirements
target_include_directories(MyLibrary PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include/")
target_link_libraries(MyLibrary PUBLIC fmt::fmt)
target_compile_definitions(MyLibrary PUBLIC RESOURCES_PATH=\"./resources/\") #"

# Profile Optimization Rules (Dev vs Prod Settings)
target_compile_definitions(MyLibrary PUBLIC
    $<$<CONFIG:Debug>:DEVELOPMENT_MODE=1>
    $<$<CONFIG:Release>:NDEBUG>
)

target_compile_options(MyLibrary PRIVATE
    $<$<CONFIG:Debug>:-Wall -Wextra -Wpedantic> # High strictness for dev warnings
    $<$<CONFIG:Release>:-O3>                     # Max machine-code optimizations for production
)

# Enable LTO solely for release binary compilation loops
if(ipo_supported)
    set_target_properties(MyLibrary PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
endif()

# ==========================================
# 6. CONDITIONAL EXECUTABLE TARGET (From ./src/)
# ==========================================
if(BUILD_EXECUTABLE)
    file(GLOB EXE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
    add_executable(MyProject ${EXE_SOURCES})
    
    # Connect internal architectures
    target_link_libraries(MyProject PRIVATE MyLibrary)

    # Static deployment options for portability
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_link_options(MyProject PRIVATE "-static-libgcc" "-static-libstdc++" "-static")
    endif()
endif()
