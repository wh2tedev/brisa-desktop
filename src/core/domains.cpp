#include "domains.h"

#include <algorithm>
#include <cctype>

namespace brisa {

std::string toLower(std::string_view text) {
    std::string out(text);
    std::transform(out.begin(), out.end(), out.begin(),
                   [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return out;
}

bool domainMatches(const std::unordered_set<std::string>& domains, std::string_view host) {
    std::string current = toLower(host);
    while (!current.empty()) {
        if (domains.count(current)) return true;
        const auto dot = current.find('.');
        if (dot == std::string::npos) return false;
        current.erase(0, dot + 1);
    }
    return false;
}

}  // namespace brisa
