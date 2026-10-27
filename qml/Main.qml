import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtWebEngine
import Brisa

ApplicationWindow {
    id: win

    width: 1180
    height: 780
    minimumWidth: 480
    minimumHeight: 360
    visible: true
    color: Theme.bg
    title: current && current.title !== "" ? current.title + " — Brisa" : "Brisa"

    Material.theme: Theme.dark ? Material.Dark : Material.Light
    Material.accent: Theme.accent
    Material.background: Theme.bg
    Material.foreground: Theme.onBg

    property var tabs: []
    property int currentIndex: -1
    readonly property var current: currentIndex >= 0 && currentIndex < tabs.length ? tabs[currentIndex] : null
    property bool pageFullScreen: false
    property bool starred: false
    property int nextDownloadId: 1
    property var activeDownloads: ({})

    ListModel { id: downloads }

    function refreshStar() {
        starred = current !== null && current.pageUrl !== "" && Browser.isBookmarked(current.pageUrl)
    }

    function saveTabs() {
        if (!Settings.values.restoreTabs) return
        const urls = tabs.filter(t => !t.isPrivate && t.pageUrl !== "").map(t => t.pageUrl)
        Settings.set("openTabs", urls)
    }

    function openTab(url, isPrivate, opener) {
        const tab = tabComponent.createObject(stack, { isPrivate: !!isPrivate, opener: opener || null })
        tab.closeRequested.connect(function() { closeTab(tab) })
        tab.popupRequested.connect(function(request) {
            const popup = openTab("", tab.isPrivate, tab)
            request.openIn(popup.view)
        })
        tab.fullScreenChanged.connect(function(on) {
            win.pageFullScreen = on
            win.visibility = on ? Window.FullScreen : Window.Windowed
        })
        tab.pageUrlChanged.connect(function() {
            if (tab === win.current) refreshStar()
            saveTabs()
        })
        tabs = tabs.concat([tab])
        currentIndex = tabs.length - 1
        if (url) tab.load(url)
        return tab
    }

    function closeTab(tab) {
        const index = tabs.indexOf(tab)
        if (index < 0) return
        const wasCurrent = tab === current
        const remaining = tabs.filter(t => t !== tab)
        const returnTo = wasCurrent && tab.opener && remaining.indexOf(tab.opener) >= 0 ? tab.opener : null
        const stay = wasCurrent ? null : current

        tabs = remaining
        tab.destroy()

        if (remaining.length === 0) {
            openTab(Browser.homeUrl(), false)
        } else if (returnTo) {
            currentIndex = remaining.indexOf(returnTo)
        } else if (stay) {
            currentIndex = remaining.indexOf(stay)
        } else {
            currentIndex = Math.min(index, remaining.length - 1)
        }
        saveTabs()
    }

    function selectRelative(step) {
        if (tabs.length > 0) currentIndex = (currentIndex + step + tabs.length) % tabs.length
    }

    function navigate(text) {
        if (current) current.load(text)
    }

    function openFromPanel(url) {
        panel.close()
        navigate(url)
    }

    function toggleBookmark() {
        if (!current || current.pageUrl === "") return
        Browser.toggleBookmark(current.pageUrl, current.title)
        refreshStar()
    }

    function toggleSite() {
        if (current && current.host !== "") Browser.setSiteAllowed(current.host, !Browser.siteAllowed(current.host))
    }

    function menuAction(action) {
        switch (action) {
        case "newTab": openTab(Browser.homeUrl(), false); break
        case "newPrivateTab": openTab(Browser.homeUrl(), true); break
        case "bookmark": toggleBookmark(); break
        case "site": toggleSite(); break
        case "bookmarks":
        case "history":
        case "downloads":
        case "settings": panel.show(action); break
        case "quit": Qt.quit(); break
        }
    }

    // --- downloads -------------------------------------------------------------------------

    function askDownload(request) {
        if (!Settings.values.confirmDownloads && !Browser.isDangerousFile(request.downloadFileName)) {
            startDownload(request)
            return
        }
        downloadDialog.request = request
        downloadDialog.open()
    }

    function downloadRow(id) {
        for (let i = 0; i < downloads.count; i++) {
            if (downloads.get(i).downloadId === id) return i
        }
        return -1
    }

    function startDownload(request) {
        const id = nextDownloadId++
        request.downloadDirectory = Settings.values.downloadDir
        activeDownloads[id] = request
        downloads.insert(0, { downloadId: id, name: request.downloadFileName, path: "", total: request.totalBytes,
                              received: 0, state: "progress" })

        request.receivedBytesChanged.connect(function() {
            const row = downloadRow(id)
            if (row >= 0) {
                downloads.setProperty(row, "received", request.receivedBytes)
                downloads.setProperty(row, "total", request.totalBytes)
            }
        })
        request.stateChanged.connect(function() {
            const row = downloadRow(id)
            if (row < 0) return
            if (request.state === WebEngineDownloadRequest.DownloadCompleted) {
                downloads.setProperty(row, "state", "done")
                downloads.setProperty(row, "name", request.downloadFileName)
                downloads.setProperty(row, "path", request.downloadDirectory + "/" + request.downloadFileName)
                delete activeDownloads[id]
            } else if (request.state === WebEngineDownloadRequest.DownloadCancelled
                       || request.state === WebEngineDownloadRequest.DownloadInterrupted) {
                downloads.setProperty(row, "state", "failed")
                delete activeDownloads[id]
            }
        })
        request.accept()
    }

    function removeDownload(index, deleteFile) {
        const item = downloads.get(index)
        if (deleteFile && item.state === "done" && item.path !== "") Browser.deleteFile(item.path)
        downloads.remove(index)
    }

    function cancelDownload(index) {
        const request = activeDownloads[downloads.get(index).downloadId]
        if (request) request.cancel()
    }

    Connections {
        target: Browser.persistentProfile
        function onDownloadRequested(request) { win.askDownload(request) }
    }
    Connections {
        target: Browser.privateProfile
        function onDownloadRequested(request) { win.askDownload(request) }
    }

    onCurrentChanged: {
        for (const tab of tabs) tab.active = tab === current
        refreshStar()
        saveTabs()
    }

    Component.onCompleted: {
        const saved = Settings.values.restoreTabs ? Settings.values.openTabs.slice() : []
        if (saved.length === 0) {
            openTab(Browser.homeUrl(), false)
            return
        }
        saved.forEach(url => openTab(url, false))
        currentIndex = 0
    }

    // --- layout ----------------------------------------------------------------------------

    Component { id: tabComponent; BrowserTab {} }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            visible: !win.pageFullScreen
            color: Theme.toolbar
            implicitHeight: chrome.implicitHeight + 8

            ColumnLayout {
                id: chrome
                width: parent.width
                spacing: 0

                TabStrip {
                    Layout.fillWidth: true
                    tabs: win.tabs
                    currentIndex: win.currentIndex
                    onSelected: function(index) { win.currentIndex = index }
                    onClosed: function(index) { win.closeTab(win.tabs[index]) }
                    onNewTab: win.openTab(Browser.homeUrl(), false)
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.topMargin: 4
                    spacing: 4

                    IconButton {
                        icon: Icons.back
                        text: "Back"
                        enabled: win.current !== null && win.current.view.canGoBack
                        onClicked: win.current.view.goBack()
                    }
                    IconButton {
                        icon: Icons.forward
                        text: "Forward"
                        enabled: win.current !== null && win.current.view.canGoForward
                        onClicked: win.current.view.goForward()
                    }
                    IconButton {
                        icon: win.current && win.current.loading ? Icons.close : Icons.refresh
                        text: win.current && win.current.loading ? "Stop" : "Reload"
                        onClicked: win.current.loading ? win.current.view.stop() : win.current.view.reload()
                    }

                    AddressBar {
                        id: addressBar
                        Layout.fillWidth: true
                        tab: win.current
                        onSubmitted: function(text) { win.navigate(text) }
                    }

                    Label {
                        visible: win.current !== null && win.current.blocked > 0
                        text: win.current ? win.current.blocked + " blocked" : ""
                        color: Theme.muted
                        font.pixelSize: 12
                        Accessible.name: text
                    }
                    IconButton {
                        icon: win.starred ? Icons.star : Icons.starOutline
                        iconColor: win.starred ? Theme.accent : Theme.onBg
                        text: win.starred ? "Remove bookmark" : "Add bookmark"
                        onClicked: win.toggleBookmark()
                    }
                    IconButton {
                        id: menuButton
                        icon: Icons.more
                        text: "Menu"
                        onClicked: menu.opened ? menu.close() : menu.open()
                    }
                }
            }
        }

        Item {
            id: stack
            Layout.fillWidth: true
            Layout.fillHeight: true

            ProgressBar {
                z: 1
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 3
                from: 0
                to: 100
                value: win.current ? win.current.progress : 0
                visible: win.current !== null && win.current.loading
                background: null
            }
        }
    }

    MenuPopup {
        id: menu
        parent: Overlay.overlay
        x: win.width - width - 8
        y: menuButton.mapToItem(null, 0, menuButton.height).y + 4
        tab: win.current
        onChosen: function(action) { win.menuAction(action) }
    }

    SidePanel {
        id: panel
        parent: Overlay.overlay
        x: win.width - width - 8
        y: menu.y
        height: win.height - y - 8
        downloads: downloads
        onOpenRequested: function(url) { win.openFromPanel(url) }
        onOpenFile: function(path) { Qt.openUrlExternally(Browser.fileUrl(path)) }
        onRemoveDownload: function(index, deleteFile) { win.removeDownload(index, deleteFile) }
        onCancelDownload: function(index) { win.cancelDownload(index) }
        onClearDataRequested: clearDialog.open()
        onChooseFolderRequested: folderDialog.open()
    }

    DownloadDialog {
        id: downloadDialog
        onConfirmed: function(request) { win.startDownload(request) }
    }

    ClearDataDialog {
        id: clearDialog
        onConfirmed: function(history, cookies, cache, downloadList) {
            Browser.clearData(history, cookies, cache)
            if (downloadList) downloads.clear()
        }
    }

    FolderDialog {
        id: folderDialog
        title: "Choose download folder"
        onAccepted: Settings.set("downloadDir", Browser.localPath(selectedFolder))
    }

    // --- shortcuts -------------------------------------------------------------------------

    Shortcut { sequence: "Ctrl+T"; onActivated: win.openTab(Browser.homeUrl(), false) }
    Shortcut { sequence: "Ctrl+Shift+N"; onActivated: win.openTab(Browser.homeUrl(), true) }
    Shortcut { sequence: "Ctrl+W"; onActivated: if (win.current) win.closeTab(win.current) }
    Shortcut { sequences: ["Ctrl+L", "F6", "Alt+D"]; onActivated: addressBar.focusAndSelect() }
    Shortcut { sequences: ["F5", "Ctrl+R"]; onActivated: if (win.current) win.current.view.reload() }
    Shortcut { sequence: "Alt+Left"; onActivated: if (win.current) win.current.view.goBack() }
    Shortcut { sequence: "Alt+Right"; onActivated: if (win.current) win.current.view.goForward() }
    Shortcut { sequence: "Ctrl+D"; onActivated: win.toggleBookmark() }
    Shortcut { sequence: "Ctrl+Tab"; onActivated: win.selectRelative(1) }
    Shortcut { sequence: "Ctrl+Shift+Tab"; onActivated: win.selectRelative(-1) }
    Shortcut { sequence: "Ctrl+B"; onActivated: panel.show("bookmarks") }
    Shortcut { sequence: "Ctrl+H"; onActivated: panel.show("history") }
    Shortcut { sequence: "Ctrl+J"; onActivated: panel.show("downloads") }
    Shortcut { sequence: "Ctrl+,"; onActivated: panel.show("settings") }
    Shortcut { sequence: "Ctrl+Q"; onActivated: Qt.quit() }
}
