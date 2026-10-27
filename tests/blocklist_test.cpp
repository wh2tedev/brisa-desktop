#include "blocklist.h"
#include "check.h"

using namespace brisa;

int main() {
    Blocklist list;
    list.loadStandard({"doubleclick.net", "Ads.Example.org"});
    list.loadStrict({"tagmanager.example"});

    CHECK(list.isBlocked("doubleclick.net"));
    CHECK(list.isBlocked("stats.g.doubleclick.net"));
    CHECK(list.isBlocked("x.ads.example.org"));
    CHECK(list.isBlocked("STATS.DoubleClick.NET"));

    CHECK(!list.isBlocked("notdoubleclick.net"));
    CHECK(!list.isBlocked("example.org"));
    CHECK(!list.isBlocked("net"));
    CHECK(!list.isBlocked(""));

    CHECK(!list.isBlocked("cdn.tagmanager.example"));
    CHECK(list.isBlocked("cdn.tagmanager.example", true));
    CHECK(list.isBlocked("doubleclick.net", true));

    const auto parsed = Blocklist::parse("# comment\n\n  one.test  \r\ntwo.test\n#three.test\nfour.test");
    CHECK(parsed.size() == 3);
    CHECK_EQ("one.test", parsed.at(0));
    CHECK_EQ("four.test", parsed.at(2));

    return failures == 0 ? 0 : 1;
}
