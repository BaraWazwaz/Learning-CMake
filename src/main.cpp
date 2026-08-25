#include <iostream>
#include <fmt/core.h>
#include "header.hpp"

int main() {
    fmt::print("Hello {}! Automated CMake setups are great!\n", "Docker-ready world");
    std::cout << get_secret() << std::endl;
    return 0;
}