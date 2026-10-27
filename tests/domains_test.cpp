#include "check.h"
#include "domains.h"

using namespace brisa;

int main() {
    const std::unordered_set<std::string> set = {"example.com", "shop.test"};

    CHECK(domainMatches(set, "example.com"));
    CHECK(domainMatches(set, "www.example.com"));
    CHECK(domainMatches(set, "a.b.shop.test"));
    CHECK(domainMatches(set, "WWW.Example.COM"));

    CHECK(!domainMatches(set, "badexample.com"));
    CHECK(!domainMatches(set, "com"));
    CHECK(!domainMatches(set, "test"));
    CHECK(!domainMatches(set, ""));

    return failures == 0 ? 0 : 1;
}
