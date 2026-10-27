find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 QuickShapes WebEngineCore WebEngineQuick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(brisa main.cpp)

set_source_files_properties(../../qml/Theme.qml ../../qml/Icons.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(brisa
    URI Brisa
    VERSION 1.0
    SOURCES
        browser.cpp
        browser.h
        json_list.h
        request_interceptor.cpp
        request_interceptor.h
        settings.cpp
        settings.h
    QML_FILES
        ../../qml/Main.qml
        ../../qml/Theme.qml
        ../../qml/Icons.qml
        ../../qml/Icon.qml
        ../../qml/IconButton.qml
        ../../qml/AddressBar.qml
        ../../qml/BrowserTab.qml
        ../../qml/TabStrip.qml
        ../../qml/MenuPopup.qml
        ../../qml/SidePanel.qml
        ../../qml/ListPanel.qml
        ../../qml/DownloadsPanel.qml
        ../../qml/DownloadDialog.qml
        ../../qml/ClearDataDialog.qml
        ../../qml/SettingsPanel.qml
        ../../qml/SettingSwitch.qml
        ../../qml/SettingCombo.qml
)

qt_add_resources(brisa brisa_files
    PREFIX /brisa
    BASE ../../resources
    FILES
        ../../resources/error.html
        ../../resources/blocklists/blocklist.txt
        ../../resources/blocklists/blocklist_strict.txt
)

target_compile_definitions(brisa PRIVATE BRISA_VERSION="${PROJECT_VERSION}")
target_include_directories(brisa PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(brisa PRIVATE
    brisa_core
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::QuickShapes
    Qt6::WebEngineCore Qt6::WebEngineQuick
)

install(TARGETS brisa RUNTIME DESTINATION bin)
install(FILES ../../packaging/brisa.desktop DESTINATION share/applications)
install(FILES ../../packaging/brisa.metainfo.xml DESTINATION share/metainfo)
install(FILES ../../packaging/brisa.svg DESTINATION share/icons/hicolor/scalable/apps)
