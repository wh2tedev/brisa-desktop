# Brisa Desktop

A minimal, privacy-focused web browser for Linux, built with Qt 6 and Qt WebEngine (Chromium).
It is the desktop companion of [Brisa for Android](https://github.com/OWNER/brisa): same design, same
rules, same philosophy. No accounts, no analytics, no servers of its own.

> **Status: v0.1, first working version.** See [Known limits](#known-limits).

## Features

- Tabs, address bar that shows only the domain, bookmarks, optional history, downloads with confirmation.
- Address rules: `localhost:3000`, `192.168.1.10:8080`, `printer.local` open over HTTP; public domains open over HTTPS;
  everything else is a search. Google, DuckDuckGo, Bing, Brave Search, Ecosia and Startpage are built in.
- HTTPS first: public `http://` links are tried over HTTPS and fall back to HTTP only if the connection fails.
  Certificate errors can never be bypassed.
- Tracker and ad blocking (Off, Standard, Strict), per-site exceptions and a blocked counter.
- Third-party cookies blocked, Do Not Track and Global Privacy Control sent, camera, microphone and location denied.
- Private tabs backed by a separate profile that never touches the disk.
- Dark, light or system theme, pure black option, seven accent colors, subtle motion that can be turned off.

## Install

Download the `.deb` for your CPU from the releases page and install it:

```sh
sudo apt install ./brisa_0.1.0_arm64.deb
```

Brisa needs Qt 6.8 or newer, so the package targets **Debian 13 (trixie) or newer** and Ubuntu 25.04 or newer.
Ubuntu 24.04 ships Qt 6.4 and is not supported.

## Build from source

Dependencies on Debian 13:

```sh
sudo apt install build-essential cmake ninja-build pkg-config \
  qt6-base-dev qt6-declarative-dev qt6-declarative-dev-tools qt6-webengine-dev qt6-webengine-dev-tools \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts qml6-module-qtquick-templates \
  qml6-module-qtquick-window qml6-module-qtquick-shapes qml6-module-qtquick-dialogs qml6-module-qtwebengine \
  qml6-module-qtqml-workerscript
```

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build --output-on-failure
./build/src/app/brisa
```

The URL, domain and blocklist logic has no Qt dependency. To build and test only that part (no Qt needed):

```sh
cmake -S . -B build -G Ninja -DBRISA_BUILD_APP=OFF
cmake --build build && ctest --test-dir build
```

### Debian package

```sh
cd build && cpack
```

This writes `brisa_<version>_<arch>.deb`. The architecture comes from the machine that builds it, so build on an
arm64 machine (or an arm64 runner) to get an arm64 package. Add `-DBRISA_REQUIRE_ARM64=ON` to make any other
architecture an error; the release workflow does this.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| Ctrl+T / Ctrl+Shift+N | New tab / new private tab |
| Ctrl+W | Close tab |
| Ctrl+Tab / Ctrl+Shift+Tab | Next / previous tab |
| Ctrl+L, F6, Alt+D | Focus the address bar |
| F5, Ctrl+R | Reload |
| Alt+Left / Alt+Right | Back / forward |
| Ctrl+D | Add or remove bookmark |
| Ctrl+B, Ctrl+H, Ctrl+J | Bookmarks, history, downloads |
| Ctrl+, | Settings |
| Ctrl+Q | Quit |

## Known limits

- No find in page, HTTP authentication dialog, per-site permission prompts or context menu yet (planned for 0.2).
  Until then, every permission request is denied and authentication requests are not answered.
- Third-party cookie blocking needs the cookie store on Qt Quick profiles. If your Qt build lacks it, Brisa says so in
  Settings and does not block them.
- Private tabs share one off-the-record session until the app quits.
- The blocked counter is kept per site, so two tabs on the same site share one count.
- "Third party" is decided by host names without a public-suffix list, so a few unusual domains may be misjudged.
- Linux exposes no system-wide "reduce motion" setting that Qt can read, so it is a setting in Brisa.
- Clearing cookies on exit is asked of the engine as the app closes and may not finish on a slow disk.
- No Safe Browsing or other reputation service is used.
- The page-rendering engine is Chromium inside Qt WebEngine and is updated with Qt, not with Brisa.

## License

MIT, see [LICENSE](LICENSE). Third-party components are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
