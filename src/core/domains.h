#pragma once

#include <string_view>
#include <unordered_set>
#include <string>

namespace brisa {

std::string toLower(std::string_view text);

// True if the host, or any parent domain of it, is in the set.
bool domainMatches(const std::unordered_set<std::string>& domains, std::string_view host);

}  // namespace brisa
