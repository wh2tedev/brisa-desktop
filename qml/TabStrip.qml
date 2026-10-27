import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Item {
    id: strip

    property var tabs: []
    property int currentIndex: -1

    signal selected(int index)
    signal closed(int index)
    signal newTab()

    implicitHeight: 40

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            clip: true
            spacing: 4
            model: strip.tabs
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: strip.currentIndex
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Item {
                id: pill
                required property var modelData
                required property int index
                readonly property bool active: index === strip.currentIndex

                width: Math.max(96, Math.min(220, (list.width - 8 * strip.tabs.length) / Math.max(1, strip.tabs.length)))
                height: list.height - 6
                y: 6

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius
                    color: pill.active ? Theme.bg : (hover.hovered ? Qt.alpha(Theme.onBg, 0.08) : "transparent")
                    Behavior on color { ColorAnimation { duration: Theme.fast } }
                }

                HoverHandler { id: hover }
                TapHandler { onTapped: strip.selected(pill.index) }
                TapHandler { acceptedButtons: Qt.MiddleButton; onTapped: strip.closed(pill.index) }

                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.title || "New tab"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 4
                    spacing: 6

                    Rectangle {
                        visible: modelData.isPrivate
                        width: 8; height: 8; radius: 4
                        color: Theme.accent
                    }
                    Label {
                        Layout.fillWidth: true
                        text: (modelData.loading && modelData.title === "" ? "Loading…" : modelData.title) || "New tab"
                        color: pill.active ? Theme.onBg : Theme.muted
                        elide: Text.ElideRight
                        font.pixelSize: 13
                    }
                    IconButton {
                        icon: Icons.close
                        iconSize: 14
                        implicitWidth: 24
                        implicitHeight: 24
                        text: "Close tab"
                        onClicked: strip.closed(pill.index)
                    }
                }
            }

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.fast }
            }
        }

        IconButton {
            icon: Icons.add
            text: "New tab"
            onClicked: strip.newTab()
        }
    }
}
