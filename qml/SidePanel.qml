import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Popup {
    id: panel

    property string mode: "bookmarks"
    property var downloads: null

    signal openRequested(string url)
    signal openFile(string path)
    signal removeDownload(int index, bool deleteFile)
    signal cancelDownload(int index)
    signal clearDataRequested()
    signal chooseFolderRequested()

    function show(newMode) {
        mode = newMode
        listPanel.reload()
        if (!opened) open()
    }

    readonly property var titles: ({ bookmarks: "Bookmarks", history: "History", downloads: "Downloads", settings: "Settings" })

    width: Math.min(400, (parent ? parent.width : 400) - 16)
    padding: 16
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        id: card
        radius: Theme.radius + 4
        color: Theme.popup
        border.color: Theme.divider
        transformOrigin: Item.TopRight
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { target: card; property: "scale"; from: 0.9; to: 1; duration: Theme.slow
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.decelerate }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.fast }
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: Theme.fast
            easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.accelerate }
    }

    contentItem: ColumnLayout {
        spacing: 8

        RowLayout {
            Label {
                Layout.fillWidth: true
                text: panel.titles[panel.mode]
                color: Theme.onBg
                font.pixelSize: 18
            }
            IconButton { icon: Icons.close; text: "Close"; onClicked: panel.close() }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: panel.mode === "settings" ? 1 : panel.mode === "downloads" ? 2 : 0

            ListPanel {
                id: listPanel
                mode: panel.mode === "history" ? "history" : "bookmarks"
                onOpenRequested: function(url) { panel.openRequested(url) }
            }
            SettingsPanel {
                onClearDataRequested: panel.clearDataRequested()
                onChooseFolderRequested: panel.chooseFolderRequested()
            }
            DownloadsPanel {
                downloads: panel.downloads
                onOpenFile: function(path) { panel.openFile(path) }
                onRemoveDownload: function(index, deleteFile) { panel.removeDownload(index, deleteFile) }
                onCancelDownload: function(index) { panel.cancelDownload(index) }
            }
        }
    }
}
