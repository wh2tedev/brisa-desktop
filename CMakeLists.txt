cmake_minimum_required(VERSION 3.21)
project(brisa VERSION 0.1.0 DESCRIPTION "A minimal, privacy-focused web browser" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(BRISA_BUILD_APP "Build the browser (needs Qt 6.8 with Qt WebEngine)" ON)
option(BRISA_BUILD_TESTS "Build the unit tests" ON)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

add_subdirectory(src/core)

if(BRISA_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(BRISA_BUILD_APP)
    add_subdirectory(src/app)
    include(${PROJECT_SOURCE_DIR}/cmake/Packaging.cmake)
endif()
