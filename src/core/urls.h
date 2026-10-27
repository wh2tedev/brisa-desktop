#pragma once

#include <functional>
#include <string>
#include <string_view>

namespace brisa::urls {

// localhost, single-label names, *.local, *.localhost and private IPv4 ranges stay on plain HTTP.
bool isPrivateHost(std::string_view host);

// Host part of what the user typed, without scheme handling. Empty if there is none.
std::string hostOf(std::string_view text);

// Turns what was typed into an address, or into a search when it does not look like one.
std::string resolve(std::string_view input, const std::function<std::string(const std::string&)>& search);

// Percent-encodes a search query for use in a URL.
std::string encodeQuery(std::string_view query);

}  // namespace brisa::urls
