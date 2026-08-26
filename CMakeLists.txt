cmake_minimum_required(VERSION 3.19.2)

# ==========================================
# 1. TOOLCHAIN & COMPILER CONFIGURATION
# ==========================================
if(WIN32)
    set(CMAKE_C_COMPILER "C:/msys64/ucrt64/bin/gcc.exe")
    set(CMAKE_CXX_COMPILER "C:/msys64/ucrt64/bin/g++.exe")
endif()

project(MyProject LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set default fallback configuration for single-config generators
# (like MinGW Makefiles)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
        "Choose the build type: Debug or Release"
        FORCE
    )
endif()

# ==========================================
# 2. USER SWITCHES & OPTIONS
# ==========================================
option(BUILD_EXECUTABLE "Build the main application executable" ON)

# ==========================================
# 3. VENDORED DEPENDENCIES
# ==========================================

set(EXTERNAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external")

# -------------------------
# fmt
# -------------------------

set(FMT_TEST OFF CACHE BOOL "Build fmt tests" FORCE)
set(FMT_DOC OFF CACHE BOOL "Build fmt documentation" FORCE)
set(FMT_INSTALL OFF CACHE BOOL "Generate fmt install target" FORCE)

add_subdirectory(${EXTERNAL_DIR}/fmt ${EXTERNAL_DIR}/fmt/build)

# ==========================================
# 4. INTERPROCEDURAL OPTIMIZATION (PROD ONLY)
# ==========================================

include(CheckIPOSupported)

check_ipo_supported(
    RESULT ipo_supported
    OUTPUT ipo_error
    LANGUAGES CXX
)

if(ipo_supported)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
else()
    message(STATUS "IPO/LTO is not supported: ${ipo_error}")
endif()

# ==========================================
# 5. INDEPENDENT LIBRARY TARGET (From ./lib/)
# ==========================================

file(GLOB LIB_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/lib/*.cpp")

if(NOT LIB_SOURCES)
    message(FATAL_ERROR "No library source files found in ${CMAKE_CURRENT_SOURCE_DIR}/lib/")
endif()

add_library(MyLibrary ${LIB_SOURCES})

# Target Requirements
target_include_directories(MyLibrary PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(MyLibrary PUBLIC fmt::fmt)

target_compile_definitions(
    MyLibrary 
    PUBLIC 
    RESOURCES_PATH=\"./resources/\" #"
)

# Profile Optimization Rules
target_compile_definitions(MyLibrary
    PUBLIC
        $<$<CONFIG:Debug>:DEVELOPMENT_MODE=1>
        $<$<CONFIG:Release>:NDEBUG>
)

target_compile_options(MyLibrary
    PRIVATE
        $<$<CONFIG:Debug>:-Wall>
        $<$<CONFIG:Debug>:-Wextra>
        $<$<CONFIG:Debug>:-Wpedantic>

        $<$<CONFIG:Release>:-O3>
)

# Enable LTO solely for Release builds
if(ipo_supported)
    set_target_properties(MyLibrary PROPERTIES INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
endif()

# ==========================================
# 6. CONDITIONAL EXECUTABLE TARGET (From ./src/)
# ==========================================

if(BUILD_EXECUTABLE)

    file(GLOB EXE_SOURCES CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

    if(NOT EXE_SOURCES)
        message(FATAL_ERROR "No executable source files found in ${CMAKE_CURRENT_SOURCE_DIR}/src/")
    endif()

    add_executable(MyProject ${EXE_SOURCES})
    target_link_libraries(MyProject PRIVATE MyLibrary)

    # Static deployment options for portability
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_link_options(MyProject PRIVATE "-static-libgcc" "-static-libstdc++" "-static")
    endif()

endif()
