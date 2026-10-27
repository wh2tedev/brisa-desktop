import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

Item {
    id: bar

    property var tab: null
    signal submitted(string text)

    implicitHeight: Theme.controlHeight

    function focusAndSelect() {
        field.forceActiveFocus()
        field.selectAll()
    }

    function refresh() {
        if (field.activeFocus) return
        field.text = displayText()
    }

    function displayText() {
        if (!tab || tab.pageUrl === "" || tab.pageUrl === "about:blank") return ""
        if (Settings.values.fullUrl) return tab.pageUrl
        const host = tab.host
        return host.startsWith("www.") ? host.substring(4) : (host !== "" ? host : tab.pageUrl)
    }

    function accept(text) {
        suggestions.close()
        field.focus = false
        bar.submitted(text)
    }

    onTabChanged: refresh()
    Connections {
        target: bar.tab
        function onPageUrlChanged() { bar.refresh() }
    }
    Connections {
        target: Settings
        function onChanged() { bar.refresh() }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.field
        border.width: field.activeFocus ? 2 : 1
        border.color: field.activeFocus ? Theme.accent : Theme.divider
        Behavior on border.color { ColorAnimation { duration: Theme.fast } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 6
        spacing: 8

        Icon {
            readonly property string scheme: bar.tab ? Browser.scheme(bar.tab.pageUrl) : ""
            path: field.activeFocus ? Icons.search
                : scheme === "https" ? Icons.lock
                : scheme === "http" ? Icons.lockOpen : Icons.search
            color: !field.activeFocus && scheme === "http" ? Theme.warning : Theme.muted
            size: 16
            Accessible.role: Accessible.StaticText
            Accessible.name: scheme === "https" ? "Secure connection" : scheme === "http" ? "Connection not secure" : "Search"
        }

        TextField {
            id: field
            Layout.fillWidth: true
            Layout.fillHeight: true
            background: null
            color: Theme.onBg
            placeholderText: "Search or type a URL"
            placeholderTextColor: Theme.muted
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            inputMethodHints: Qt.ImhUrlCharactersOnly | Qt.ImhNoPredictiveText
            Accessible.name: "Address bar"

            onActiveFocusChanged: {
                if (activeFocus) {
                    text = bar.tab ? bar.tab.pageUrl : ""
                    selectAll()
                } else {
                    suggestions.close()
                    bar.refresh()
                }
            }
            onTextEdited: {
                list.model = Browser.suggestions(text)
                list.currentIndex = -1
                if (list.count > 0) suggestions.open(); else suggestions.close()
            }
            onAccepted: {
                const picked = list.currentIndex >= 0 ? list.model[list.currentIndex].url : Browser.resolve(text)
                bar.accept(picked)
            }
            Keys.onDownPressed: if (list.count > 0) list.currentIndex = Math.min(list.currentIndex + 1, list.count - 1)
            Keys.onUpPressed: list.currentIndex = Math.max(list.currentIndex - 1, -1)
            Keys.onEscapePressed: { suggestions.close(); focus = false }
        }

        Item { Layout.preferredWidth: 0 }
    }

    Popup {
        id: suggestions
        y: bar.height + 6
        width: bar.width
        padding: 6
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        focus: false

        background: Rectangle {
            radius: Theme.radius
            color: Theme.popup
            border.color: Theme.divider
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.fast
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.decelerate }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; to: 0; duration: Theme.fast
                easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.accelerate }
        }

        contentItem: ListView {
            id: list
            implicitHeight: Math.min(contentHeight, 360)
            clip: true
            interactive: false
            delegate: ItemDelegate {
                width: list.width
                height: 44
                highlighted: ListView.isCurrentItem
                onClicked: bar.accept(modelData.url)
                contentItem: RowLayout {
                    spacing: 10
                    Icon {
                        path: modelData.kind === "search" ? Icons.search
                            : modelData.kind === "bookmark" ? Icons.star : Icons.refresh
                        color: Theme.muted
                        size: 16
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.title
                        color: Theme.onBg
                        elide: Text.ElideRight
                    }
                    Label {
                        text: modelData.detail
                        color: Theme.muted
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.maximumWidth: 180
                    }
                }
                background: Rectangle {
                    radius: 8
                    color: parent.highlighted ? Qt.alpha(Theme.accent, 0.16)
                         : parent.hovered ? Qt.alpha(Theme.onBg, 0.08) : "transparent"
                }
            }
        }
    }
}
