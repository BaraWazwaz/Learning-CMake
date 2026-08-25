#include <sstream>
#include <fstream>

#include "header.hpp"

std::string get_secret() {
    std::ifstream file (RESOURCES_PATH "file.txt");
    std::stringstream str;
    std::string line;
    while (std::getline(file, line)) {
        str << line << "\n";
    }
    return str.str();
}
