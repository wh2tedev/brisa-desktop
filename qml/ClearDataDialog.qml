import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Dialog {
    id: dialog

    signal confirmed(bool history, bool cookies, bool cache, bool downloads)

    title: "Clear browsing data"
    modal: true
    anchors.centerIn: Overlay.overlay
    standardButtons: Dialog.Ok | Dialog.Cancel
    background: Rectangle { radius: Theme.radius + 4; color: Theme.popup; border.color: Theme.divider }

    onAccepted: confirmed(history.checked, cookies.checked, cache.checked, downloads.checked)

    ColumnLayout {
        CheckBox { id: history; text: "Browsing history"; checked: true }
        CheckBox { id: cookies; text: "Cookies and site data"; checked: true }
        CheckBox { id: cache; text: "Cached files"; checked: true }
        CheckBox { id: downloads; text: "Download list (files stay on disk)" }
    }
}
