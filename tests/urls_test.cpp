#include "check.h"
#include "search_engines.h"
#include "urls.h"

using namespace brisa;

static std::string resolve(const std::string& input) {
    return urls::resolve(input, [](const std::string& q) { return "search:" + q; });
}

int main() {
    // explicit web addresses are kept
    CHECK_EQ("https://example.com/a", resolve("https://example.com/a"));
    CHECK_EQ("http://example.com", resolve("  http://example.com "));

    // local addresses use http
    CHECK_EQ("http://localhost:3000", resolve("localhost:3000"));
    CHECK_EQ("http://192.168.1.10:8080/admin", resolve("192.168.1.10:8080/admin"));
    CHECK_EQ("http://printer.local", resolve("printer.local"));
    CHECK_EQ("http://[::1]:5173", resolve("[::1]:5173"));
    CHECK_EQ("http://172.20.0.1", resolve("172.20.0.1"));
    CHECK_EQ("http://app.localhost:8000", resolve("app.localhost:8000"));

    // public addresses use https
    CHECK_EQ("https://example.com", resolve("example.com"));
    CHECK_EQ("https://example.com/a?b=1", resolve("example.com/a?b=1"));
    CHECK_EQ("https://8.8.8.8", resolve("8.8.8.8"));
    CHECK_EQ("https://172.32.0.1", resolve("172.32.0.1"));
    CHECK_EQ("https://10.example.com", resolve("10.example.com"));
    CHECK_EQ("https://127.example.com", resolve("127.example.com"));
    CHECK_EQ("https://user@example.com/path", resolve("user@example.com/path"));

    // everything else is a search
    CHECK_EQ("search:hello world", resolve("hello world"));
    CHECK_EQ("search:hello", resolve("hello"));
    CHECK_EQ("search:file:///home/a.html", resolve("file:///home/a.html"));
    CHECK_EQ("search:javascript:alert(1)", resolve("javascript:alert(1)"));
    CHECK_EQ("search:", resolve("   "));

    // private hosts
    CHECK(urls::isPrivateHost("localhost"));
    CHECK(urls::isPrivateHost("myserver"));
    CHECK(urls::isPrivateHost("127.0.0.1"));
    CHECK(urls::isPrivateHost("10.1.2.3"));
    CHECK(urls::isPrivateHost("192.168.0.1"));
    CHECK(urls::isPrivateHost("169.254.1.1"));
    CHECK(urls::isPrivateHost("172.16.0.1"));
    CHECK(urls::isPrivateHost("172.31.255.1"));
    CHECK(!urls::isPrivateHost("example.com"));
    CHECK(!urls::isPrivateHost("110.1.1.1"));
    CHECK(!urls::isPrivateHost("172.15.0.1"));
    CHECK(!urls::isPrivateHost(""));

    // search engines
    CHECK_EQ("https://www.google.com/search?q=a+b%26c", searchUrl("google", "a b&c"));
    CHECK_EQ("https://duckduckgo.com/?q=caf%C3%A9", searchUrl("duckduckgo", "café"));
    CHECK_EQ("https://www.google.com/search?q=x", searchUrl("nonsense", "x"));
    CHECK(searchEngines().size() == 6);

    return failures == 0 ? 0 : 1;
}
