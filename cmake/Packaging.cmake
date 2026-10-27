# Debian package. The architecture is taken from the build machine so a package can never
# carry a binary for a different CPU. Pass -DBRISA_REQUIRE_ARM64=ON to make anything but arm64 an error.
option(BRISA_REQUIRE_ARM64 "Refuse to package unless building for aarch64" OFF)

if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
    set(BRISA_DEB_ARCH arm64)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64)$")
    set(BRISA_DEB_ARCH amd64)
else()
    set(BRISA_DEB_ARCH ${CMAKE_SYSTEM_PROCESSOR})
endif()

if(BRISA_REQUIRE_ARM64 AND NOT BRISA_DEB_ARCH STREQUAL "arm64")
    message(FATAL_ERROR "BRISA_REQUIRE_ARM64 is on but this build targets ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(CPACK_GENERATOR DEB)
set(CPACK_PACKAGING_INSTALL_PREFIX /usr)
set(CPACK_PACKAGE_NAME brisa)
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/OWNER/brisa-desktop")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")

set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Brisa contributors <brisa@users.noreply.github.com>")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${BRISA_DEB_ARCH})
set(CPACK_DEBIAN_PACKAGE_SECTION web)
set(CPACK_DEBIAN_PACKAGE_PRIORITY optional)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)

# QML modules are loaded at run time, so dpkg-shlibdeps cannot see them.
set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "qml6-module-qtquick, qml6-module-qtquick-controls, qml6-module-qtquick-layouts, qml6-module-qtquick-templates, qml6-module-qtquick-window, qml6-module-qtquick-shapes, qml6-module-qtquick-dialogs, qml6-module-qtwebengine, qml6-module-qtqml-workerscript")

include(CPack)
