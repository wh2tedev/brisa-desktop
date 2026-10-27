# Third-party notices

Brisa is released under the [MIT License](LICENSE). It is built on the open-source work below.
Nothing here changes the license of Brisa itself.

## Used by the app

| Component | License | Used for |
| --- | --- | --- |
| [Qt 6](https://www.qt.io) (Core, Gui, Qml, Quick, Quick Controls 2, Quick Shapes) | LGPL-3.0 or GPL-3.0 | Application framework and interface |
| [Qt WebEngine](https://doc.qt.io/qt-6/qtwebengine-index.html) and the [Chromium](https://www.chromium.org) code it contains | LGPL-3.0 or GPL-3.0 for Qt; BSD-3-Clause and other licenses for Chromium and its dependencies | Rendering web pages |
| [Material Design icons](https://github.com/google/material-design-icons) (some adapted) | Apache-2.0 | Interface icons |

Brisa links to Qt dynamically and does not modify it. On Debian and Ubuntu the Qt libraries come from your
distribution's packages, which carry their own license files under `/usr/share/doc`. The licenses of the
components inside Chromium are listed at `chrome://credits` in Chromium and in the Qt WebEngine documentation.
The full Apache License 2.0 text is in [`LICENSES/Apache-2.0.txt`](LICENSES/Apache-2.0.txt).

## Data

The tracker and ad domain lists in `resources/blocklists/` are the same lists used by Brisa for Android.

## Used only to build and test (not distributed)

CMake, Ninja and a C++17 compiler. The unit tests use a small helper header in the repository and no test framework.

## Trademarks

Linux is a trademark of Linus Torvalds. Google, Google Chrome, Google Search and Chromium are trademarks of
Google LLC. DuckDuckGo, Bing, Brave, Ecosia and Startpage are trademarks of their respective owners. They are used
only to name the services Brisa can open. Brisa is an independent project and is not affiliated with, sponsored or
endorsed by any of them.
