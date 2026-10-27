import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

// Bookmarks or history, depending on mode.
ColumnLayout {
    id: panel

    property string mode: "bookmarks"
    signal openRequested(string url)

    function reload() {
        model.clear()
        const items = mode === "bookmarks" ? Browser.bookmarks() : Browser.history()
        for (const item of items) model.append({ title: item.title, url: item.url })
    }

    onModeChanged: reload()
    spacing: 8

    RowLayout {
        visible: panel.mode === "history"
        Layout.fillWidth: true
        Item { Layout.fillWidth: true }
        Button {
            text: "Clear history"
            flat: true
            enabled: model.count > 0
            onClicked: { Browser.clearHistory(); panel.reload() }
        }
    }

    Label {
        visible: model.count === 0
        Layout.fillWidth: true
        Layout.topMargin: 24
        horizontalAlignment: Text.AlignHCenter
        text: panel.mode === "bookmarks" ? "No bookmarks yet" : "No history"
        color: Theme.muted
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: ListModel { id: model }
        boundsBehavior: Flickable.StopAtBounds

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: 80; duration: Theme.fast
                    easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.accelerate }
                NumberAnimation { property: "opacity"; to: 0; duration: Theme.fast }
            }
        }
        displaced: Transition {
            NumberAnimation { property: "y"; duration: Theme.slow
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.standard }
        }

        delegate: ItemDelegate {
            width: ListView.view.width
            height: 56
            onClicked: panel.openRequested(model.url)
            contentItem: RowLayout {
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label { Layout.fillWidth: true; text: model.title; color: Theme.onBg; elide: Text.ElideRight }
                    Label { Layout.fillWidth: true; text: model.url; color: Theme.muted; font.pixelSize: 12; elide: Text.ElideRight }
                }
                IconButton {
                    icon: Icons.close
                    iconSize: 16
                    text: "Remove"
                    onClicked: {
                        if (panel.mode === "bookmarks") Browser.removeBookmark(model.url)
                        else Browser.removeVisit(model.url)
                        ListView.view.model.remove(index)
                    }
                }
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? Qt.alpha(Theme.onBg, 0.08) : "transparent"
            }
        }
    }
}
