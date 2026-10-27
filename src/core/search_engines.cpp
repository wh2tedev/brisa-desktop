#include "search_engines.h"

#include "urls.h"

namespace brisa {

const std::vector<SearchEngine>& searchEngines() {
    static const std::vector<SearchEngine> engines = {
        {"google", "Google", "https://www.google.com/search?q="},
        {"duckduckgo", "DuckDuckGo", "https://duckduckgo.com/?q="},
        {"bing", "Bing", "https://www.bing.com/search?q="},
        {"brave", "Brave Search", "https://search.brave.com/search?q="},
        {"ecosia", "Ecosia", "https://www.ecosia.org/search?q="},
        {"startpage", "Startpage", "https://www.startpage.com/do/search?q="},
    };
    return engines;
}

const SearchEngine& searchEngine(std::string_view key) {
    for (const auto& engine : searchEngines()) {
        if (engine.key == key) return engine;
    }
    return searchEngines().front();
}

std::string searchUrl(std::string_view engineKey, std::string_view query) {
    return std::string(searchEngine(engineKey).queryUrl) + urls::encodeQuery(query);
}

}  // namespace brisa
