import QtQuick
import QtQuick.Controls
import Brisa

// Flat round button with a spring-like bounce on press.
AbstractButton {
    id: button
    property string icon
    property color iconColor: Theme.onBg
    property int iconSize: 20

    implicitWidth: 36
    implicitHeight: 36
    hoverEnabled: true
    focusPolicy: Qt.TabFocus

    Accessible.role: Accessible.Button
    Accessible.name: text

    scale: pressed ? 0.88 : 1
    Behavior on scale {
        enabled: !Theme.reduceMotion
        SpringAnimation { spring: 5; damping: 0.35; epsilon: 0.002 }
    }

    background: Rectangle {
        radius: width / 2
        color: button.pressed ? Qt.alpha(Theme.onBg, 0.16)
             : button.hovered || button.visualFocus ? Qt.alpha(Theme.onBg, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.fast } }
    }

    contentItem: Item {
        Icon {
            anchors.centerIn: parent
            path: button.icon
            size: button.iconSize
            color: button.enabled ? button.iconColor : Theme.muted
        }
    }
}
