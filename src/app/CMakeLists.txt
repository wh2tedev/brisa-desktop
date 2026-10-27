find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 WebEngineCore WebEngineQuick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(brisa main.cpp)

# QtQuick.Shapes is only needed as a QML module at run time; it has no public C++ package.
set(brisa_qml_files
    Main.qml
    Theme.qml
    Icons.qml
    Icon.qml
    IconButton.qml
    AddressBar.qml
    BrowserTab.qml
    TabStrip.qml
    MenuPopup.qml
    SidePanel.qml
    ListPanel.qml
    DownloadsPanel.qml
    DownloadDialog.qml
    ClearDataDialog.qml
    SettingsPanel.qml
    SettingSwitch.qml
    SettingCombo.qml
)
foreach(file IN LISTS brisa_qml_files)
    set_source_files_properties(../../qml/${file} PROPERTIES QT_RESOURCE_ALIAS ${file})
endforeach()
set_source_files_properties(../../qml/Theme.qml ../../qml/Icons.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
list(TRANSFORM brisa_qml_files PREPEND ../../qml/ OUTPUT_VARIABLE brisa_qml_files_paths)

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
    QML_FILES ${brisa_qml_files_paths}
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
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
    Qt6::WebEngineCore Qt6::WebEngineQuick
)

install(TARGETS brisa RUNTIME DESTINATION bin)
install(FILES ../../packaging/brisa.desktop DESTINATION share/applications)
install(FILES ../../packaging/brisa.metainfo.xml DESTINATION share/metainfo)
install(FILES ../../packaging/brisa.svg DESTINATION share/icons/hicolor/scalable/apps)
