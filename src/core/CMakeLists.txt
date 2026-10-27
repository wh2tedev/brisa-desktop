add_library(brisa_core STATIC
    blocklist.cpp
    domains.cpp
    search_engines.cpp
    urls.cpp
)
target_include_directories(brisa_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
