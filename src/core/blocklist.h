#pragma once

#include <string>
#include <string_view>
#include <unordered_set>
#include <vector>

namespace brisa {

// Two levels: Standard (ads and trackers) and Strict (adds tag managers and fingerprinting).
class Blocklist {
public:
    void loadStandard(const std::vector<std::string>& entries);
    void loadStrict(const std::vector<std::string>& entries);

    bool isBlocked(std::string_view host, bool strictMode = false) const;

    // One domain per line; blank lines and lines starting with '#' are ignored.
    static std::vector<std::string> parse(std::string_view text);

private:
    std::unordered_set<std::string> standard_;
    std::unordered_set<std::string> strict_;
};

}  // namespace brisa
