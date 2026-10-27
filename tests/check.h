#pragma once

#include <iostream>
#include <string>

inline int failures = 0;

#define CHECK(condition)                                                                    \
    do {                                                                                    \
        if (!(condition)) {                                                                 \
            std::cerr << __FILE__ << ":" << __LINE__ << ": check failed: " #condition "\n"; \
            ++failures;                                                                     \
        }                                                                                   \
    } while (0)

#define CHECK_EQ(expected, actual)                                                                       \
    do {                                                                                                 \
        const std::string e = (expected);                                                                \
        const std::string a = (actual);                                                                  \
        if (e != a) {                                                                                    \
            std::cerr << __FILE__ << ":" << __LINE__ << ": expected \"" << e << "\" but got \"" << a << "\"\n"; \
            ++failures;                                                                                  \
        }                                                                                                \
    } while (0)
