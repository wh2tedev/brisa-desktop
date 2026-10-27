#pragma once

#include <string>
#include <string_view>
#include <vector>

namespace brisa {

struct SearchEngine {
    std::string_view key;
    std::string_view name;
    std::string_view queryUrl;  // the query is appended
};

const std::vector<SearchEngine>& searchEngines();

// Unknown keys fall back to Google, the default.
const SearchEngine& searchEngine(std::string_view key);

std::string searchUrl(std::string_view engineKey, std::string_view query);

}  // namespace brisa
