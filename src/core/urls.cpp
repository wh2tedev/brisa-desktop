#include "urls.h"

#include "domains.h"

#include <array>
#include <cctype>

namespace brisa::urls {

namespace {

bool startsWith(std::string_view text, std::string_view prefix) {
    return text.size() >= prefix.size() && toLower(text.substr(0, prefix.size())) == prefix;
}

bool endsWith(std::string_view text, std::string_view suffix) {
    return text.size() >= suffix.size() && text.substr(text.size() - suffix.size()) == suffix;
}

// Parses a dotted IPv4 literal. Names such as "10.example.com" are not addresses.
bool parseIpv4(std::string_view host, std::array<int, 4>& octets) {
    int index = 0;
    int value = -1;
    for (char c : host) {
        if (std::isdigit(static_cast<unsigned char>(c))) {
            value = (value < 0 ? 0 : value * 10) + (c - '0');
            if (value > 255) return false;
        } else if (c == '.' && value >= 0 && index < 3) {
            octets[index++] = value;
            value = -1;
        } else {
            return false;
        }
    }
    if (value < 0 || index != 3) return false;
    octets[3] = value;
    return true;
}

bool isPrivateIpv4(std::string_view host) {
    std::array<int, 4> o{};
    if (!parseIpv4(host, o)) return false;
    return o[0] == 127 || o[0] == 10 || (o[0] == 192 && o[1] == 168) || (o[0] == 169 && o[1] == 254) ||
           (o[0] == 172 && o[1] >= 16 && o[1] <= 31);
}

}  // namespace

bool isPrivateHost(std::string_view host) {
    if (host.empty()) return false;
    const std::string h = toLower(host);
    return h.find('.') == std::string::npos || endsWith(h, ".local") || endsWith(h, ".localhost") ||
           isPrivateIpv4(h);
}

std::string hostOf(std::string_view text) {
    auto authority = text.substr(0, text.find_first_of("/?#"));
    const auto at = authority.rfind('@');
    if (at != std::string_view::npos) authority.remove_prefix(at + 1);

    if (!authority.empty() && authority.front() == '[') {
        const auto end = authority.find(']');
        return end == std::string_view::npos || end == 0 ? std::string() : toLower(authority.substr(0, end + 1));
    }
    return toLower(authority.substr(0, authority.find(':')));
}

std::string resolve(std::string_view input, const std::function<std::string(const std::string&)>& search) {
    const char* spaces = " \t\r\n";
    const auto first = input.find_first_not_of(spaces);
    if (first == std::string_view::npos) return search("");
    const auto text = input.substr(first, input.find_last_not_of(spaces) - first + 1);
    const std::string typed(text);

    if (startsWith(text, "https://") || startsWith(text, "http://")) return typed;
    if (text.find("://") != std::string_view::npos || text.find(' ') != std::string_view::npos) return search(typed);

    const std::string host = hostOf(text);
    if (host.empty()) return search(typed);
    if (host == "localhost" || host.front() == '[') return "http://" + typed;
    if (host.find('.') == std::string::npos) return search(typed);
    if (isPrivateHost(host)) return "http://" + typed;
    return "https://" + typed;
}

std::string encodeQuery(std::string_view query) {
    static const char* hex = "0123456789ABCDEF";
    std::string out;
    for (unsigned char c : query) {
        if (std::isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            out += static_cast<char>(c);
        } else if (c == ' ') {
            out += '+';
        } else {
            out += '%';
            out += hex[c >> 4];
            out += hex[c & 15];
        }
    }
    return out;
}

}  // namespace brisa::urls
