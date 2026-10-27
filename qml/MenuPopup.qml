import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Popup {
    id: menu

    property var tab: null
    property var entries: []
    signal chosen(string action)

    function rebuild() {
        const page = tab && tab.pageUrl !== ""
        const starred = page && Browser.isBookmarked(tab.pageUrl)
        const allowed = page && Browser.siteAllowed(tab.host)
        entries = [
            { action: "newTab", text: "New tab", hint: "Ctrl+T" },
            { action: "newPrivateTab", text: "New private tab", hint: "Ctrl+Shift+N" },
            { action: "-" },
            { action: "bookmark", text: starred ? "Remove bookmark" : "Add bookmark", hint: "Ctrl+D", enabled: page },
            { action: "site", text: allowed ? "Block trackers on this site" : "Allow trackers on this site", enabled: page },
            { action: "-" },
            { action: "bookmarks", text: "Bookmarks", hint: "Ctrl+B" },
            { action: "history", text: "History", hint: "Ctrl+H" },
            { action: "downloads", text: "Downloads", hint: "Ctrl+J" },
            { action: "settings", text: "Settings", hint: "Ctrl+," },
            { action: "-" },
            { action: "quit", text: "Quit", hint: "Ctrl+Q" }
        ]
    }

    width: 280
    padding: 0
    onAboutToShow: rebuild()
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: null

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { target: card; property: "scale"; from: 0.85; to: 1; duration: Theme.slow
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.decelerate }
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.fast }
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: Theme.fast
            easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.accelerate }
    }

    contentItem: Rectangle {
        id: card
        implicitHeight: column.implicitHeight + 16
        radius: Theme.radius + 4
        color: Theme.popup
        border.color: Theme.divider
        transformOrigin: Item.TopRight

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: 8
            spacing: 0

            Repeater {
                model: menu.entries
                delegate: Loader {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    Layout.preferredHeight: item ? item.implicitHeight : 0
                    sourceComponent: modelData.action === "-" ? separator : row

                    opacity: menu.opened ? 1 : 0
                    Behavior on opacity {
                        enabled: !Theme.reduceMotion
                        SequentialAnimation {
                            PauseAnimation { duration: menu.opened ? index * 20 : 0 }
                            NumberAnimation { duration: Theme.fast; easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.decelerate }
                        }
                    }
                    transform: Translate {
                        y: menu.opened ? 0 : -6
                        Behavior on y {
                            enabled: !Theme.reduceMotion
                            NumberAnimation { duration: Theme.slow; easing.type: Easing.BezierSpline
                                easing.bezierCurve: Theme.decelerate }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: separator
        Rectangle { implicitHeight: 17; color: "transparent"
            Rectangle { anchors.centerIn: parent; width: parent.width - 16; height: 1; color: Theme.divider } }
    }

    Component {
        id: row
        ItemDelegate {
            readonly property var entry: parent.modelData
            implicitHeight: 40
            enabled: entry.enabled !== false
            onClicked: { menu.close(); menu.chosen(entry.action) }
            contentItem: RowLayout {
                Label { Layout.fillWidth: true; text: entry.text; color: enabled ? Theme.onBg : Theme.muted }
                Label { text: entry.hint || ""; color: Theme.muted; font.pixelSize: 12 }
            }
            background: Rectangle {
                radius: 8
                color: parent.pressed ? Qt.alpha(Theme.onBg, 0.16) : parent.hovered || parent.visualFocus ? Qt.alpha(Theme.onBg, 0.08) : "transparent"
            }
        }
    }
}
