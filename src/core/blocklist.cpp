#include "blocklist.h"

#include "domains.h"

namespace brisa {

namespace {

std::unordered_set<std::string> toSet(const std::vector<std::string>& entries) {
    std::unordered_set<std::string> set;
    for (const auto& entry : entries) set.insert(toLower(entry));
    return set;
}

std::string_view trim(std::string_view s) {
    const char* spaces = " \t\r\n";
    const auto first = s.find_first_not_of(spaces);
    if (first == std::string_view::npos) return {};
    return s.substr(first, s.find_last_not_of(spaces) - first + 1);
}

}  // namespace

void Blocklist::loadStandard(const std::vector<std::string>& entries) { standard_ = toSet(entries); }

void Blocklist::loadStrict(const std::vector<std::string>& entries) { strict_ = toSet(entries); }

bool Blocklist::isBlocked(std::string_view host, bool strictMode) const {
    return domainMatches(standard_, host) || (strictMode && domainMatches(strict_, host));
}

std::vector<std::string> Blocklist::parse(std::string_view text) {
    std::vector<std::string> entries;
    while (!text.empty()) {
        const auto end = text.find('\n');
        const auto line = trim(text.substr(0, end));
        if (!line.empty() && line.front() != '#') entries.emplace_back(line);
        if (end == std::string_view::npos) break;
        text.remove_prefix(end + 1);
    }
    return entries;
}

}  // namespace brisa
