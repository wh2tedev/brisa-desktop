import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

RowLayout {
    id: row

    property string key
    property string text
    property string description

    Layout.fillWidth: true
    spacing: 12

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Label { Layout.fillWidth: true; text: row.text; color: Theme.onBg; wrapMode: Text.Wrap }
        Label {
            visible: row.description !== ""
            Layout.fillWidth: true
            text: row.description
            color: Theme.muted
            font.pixelSize: 12
            wrapMode: Text.Wrap
        }
    }

    Switch {
        id: toggle
        Accessible.name: row.text
        onToggled: Settings.set(row.key, checked)
    }

    // A plain binding on `checked` would be dropped after the first click.
    Binding { target: toggle; property: "checked"; value: Settings.values[row.key] }
}
