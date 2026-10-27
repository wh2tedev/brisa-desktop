import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Dialog {
    id: dialog

    property var request: null
    readonly property string fileName: request ? request.downloadFileName : ""
    readonly property bool dangerous: Browser.isDangerousFile(fileName)
    signal confirmed(var request)

    function sizeText(bytes) {
        if (bytes <= 0) return "unknown size"
        const units = ["B", "KB", "MB", "GB"]
        let value = bytes, unit = 0
        while (value >= 1024 && unit < units.length - 1) { value /= 1024; unit++ }
        return (unit === 0 ? value : value.toFixed(1)) + " " + units[unit]
    }

    title: "Download file?"
    modal: true
    anchors.centerIn: Overlay.overlay
    width: Math.min(440, Overlay.overlay ? Overlay.overlay.width - 32 : 440)
    standardButtons: Dialog.Save | Dialog.Cancel

    background: Rectangle { radius: Theme.radius + 4; color: Theme.popup; border.color: Theme.divider }

    onAccepted: confirmed(request)
    onRejected: if (request) request.cancel()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Label { Layout.fillWidth: true; text: dialog.fileName; elide: Text.ElideMiddle; font.bold: true; color: Theme.onBg }
        Label { text: dialog.sizeText(dialog.request ? dialog.request.totalBytes : 0); color: Theme.muted }
        Label { Layout.fillWidth: true; text: "Saved to " + Settings.values.downloadDir; color: Theme.muted; wrapMode: Text.Wrap }
        Label {
            visible: dialog.dangerous
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Theme.warning
            text: "This type of file can run code on your computer. Only keep it if you trust the site it came from."
        }
    }
}
