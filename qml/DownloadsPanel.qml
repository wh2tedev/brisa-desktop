import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

ColumnLayout {
    id: panel

    property var downloads: null
    signal openFile(string path)
    signal removeDownload(int index, bool deleteFile)
    signal cancelDownload(int index)

    function size(bytes) {
        if (bytes < 0) return "unknown size"
        const units = ["B", "KB", "MB", "GB"]
        let value = bytes, unit = 0
        while (value >= 1024 && unit < units.length - 1) { value /= 1024; unit++ }
        return (unit === 0 ? value : value.toFixed(1)) + " " + units[unit]
    }

    spacing: 8

    Label {
        visible: !panel.downloads || panel.downloads.count === 0
        Layout.fillWidth: true
        Layout.topMargin: 24
        horizontalAlignment: Text.AlignHCenter
        text: "No downloads"
        color: Theme.muted
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        model: panel.downloads
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
            height: 76
            contentItem: ColumnLayout {
                spacing: 4
                RowLayout {
                    Label { Layout.fillWidth: true; text: model.name; color: Theme.onBg; elide: Text.ElideMiddle }
                    Button {
                        visible: model.state === "done"
                        text: "Open"
                        flat: true
                        onClicked: panel.openFile(model.path)
                    }
                    Button {
                        visible: model.state === "progress"
                        text: "Cancel"
                        flat: true
                        onClicked: panel.cancelDownload(index)
                    }
                    IconButton {
                        visible: model.state !== "progress"
                        icon: Icons.close
                        iconSize: 16
                        text: "Delete"
                        onClicked: panel.removeDownload(index, true)
                    }
                }
                ProgressBar {
                    visible: model.state === "progress"
                    Layout.fillWidth: true
                    from: 0
                    to: Math.max(1, model.total)
                    value: model.received
                    indeterminate: model.total <= 0
                }
                Label {
                    text: model.state === "progress" ? panel.size(model.received) + " of " + panel.size(model.total)
                        : model.state === "done" ? panel.size(model.total >= 0 ? model.total : model.received)
                        : "Download failed"
                    color: model.state === "failed" ? Theme.warning : Theme.muted
                    font.pixelSize: 12
                }
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? Qt.alpha(Theme.onBg, 0.08) : "transparent"
            }
        }
    }
}
