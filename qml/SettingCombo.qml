import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

RowLayout {
    id: row

    property string key
    property string text
    property var options: []  // [{ value, text }]

    Layout.fillWidth: true
    spacing: 12

    Label { Layout.fillWidth: true; text: row.text; color: Theme.onBg; wrapMode: Text.Wrap }

    ComboBox {
        id: combo
        Layout.preferredWidth: 180
        model: row.options
        textRole: "text"
        valueRole: "value"
        Accessible.name: row.text
        onActivated: Settings.set(row.key, currentValue)
    }

    Binding {
        target: combo
        property: "currentIndex"
        value: Math.max(0, combo.indexOfValue(Settings.values[row.key]))
    }
}
