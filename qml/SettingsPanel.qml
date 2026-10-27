import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Brisa

ScrollView {
    id: panel

    signal clearDataRequested()
    signal chooseFolderRequested()

    contentWidth: availableWidth
    clip: true

    component Section: Label {
        Layout.topMargin: 16
        color: Theme.accent
        font.bold: true
    }

    ColumnLayout {
        width: panel.availableWidth
        spacing: 12

        Section { text: "General"; Layout.topMargin: 0 }
        SettingCombo {
            key: "searchEngine"
            text: "Search engine"
            options: Browser.engines.map(function(e) { return { value: e.key, text: e.name } })
        }
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Home page"; color: Theme.onBg; Layout.fillWidth: true }
            TextField {
                id: home
                Layout.preferredWidth: 180
                placeholderText: "https://www.google.com"
                text: Settings.values.homepage
                onEditingFinished: Settings.set("homepage", text.trim())
            }
        }
        SettingSwitch { key: "restoreTabs"; text: "Restore tabs on launch" }

        Section { text: "Privacy and security" }
        SettingCombo {
            key: "trackerLevel"
            text: "Tracker and ad blocking"
            options: [{ value: 0, text: "Off" }, { value: 1, text: "Standard" }, { value: 2, text: "Strict" }]
        }
        SettingSwitch {
            key: "httpsFirst"
            text: "HTTPS first"
            description: "Try HTTPS for public sites and fall back to HTTP only if the connection fails."
        }
        SettingSwitch { key: "blockThirdPartyCookies"; text: "Block third-party cookies" }
        Label {
            visible: !Browser.cookieFilterActive
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Theme.warning
            font.pixelSize: 12
            text: "Third-party cookie blocking is not available in this build of Qt."
        }
        SettingSwitch {
            key: "sendPrivacySignals"
            text: "Send Do Not Track and Global Privacy Control"
            description: "Sites may ignore these signals."
        }
        SettingSwitch { key: "saveHistory"; text: "Save browsing history" }
        SettingSwitch { key: "clearOnExit"; text: "Clear browsing data on exit" }
        Button { text: "Clear browsing data…"; onClicked: panel.clearDataRequested() }

        Label { text: "Sites with tracker blocking off"; color: Theme.onBg; Layout.topMargin: 8 }
        Label {
            visible: Settings.values.siteExceptions.length === 0
            text: "None"
            color: Theme.muted
            font.pixelSize: 12
        }
        Repeater {
            model: Settings.values.siteExceptions
            delegate: RowLayout {
                required property string modelData
                Layout.fillWidth: true
                Label { Layout.fillWidth: true; text: modelData; color: Theme.onBg; elide: Text.ElideRight }
                IconButton {
                    icon: Icons.close
                    iconSize: 16
                    text: "Remove " + modelData
                    onClicked: Browser.setSiteAllowed(modelData, false)
                }
            }
        }

        Section { text: "Downloads" }
        SettingSwitch {
            key: "confirmDownloads"
            text: "Ask before downloading"
            description: "Risky file types always ask."
        }
        RowLayout {
            Layout.fillWidth: true
            Label { Layout.fillWidth: true; text: Settings.values.downloadDir; color: Theme.muted; elide: Text.ElideMiddle }
            Button { text: "Change…"; onClicked: panel.chooseFolderRequested() }
        }

        Section { text: "Appearance" }
        SettingCombo {
            key: "theme"
            text: "Theme"
            options: [{ value: "dark", text: "Dark" }, { value: "light", text: "Light" }, { value: "system", text: "Follow system" }]
        }
        SettingSwitch { key: "pureBlack"; text: "Pure black in dark theme" }
        SettingCombo {
            key: "accent"
            text: "Accent color"
            options: [
                { value: "blue", text: "Blue" }, { value: "green", text: "Green" }, { value: "purple", text: "Purple" },
                { value: "orange", text: "Orange" }, { value: "pink", text: "Pink" }, { value: "teal", text: "Teal" },
                { value: "red", text: "Red" }
            ]
        }
        SettingSwitch { key: "fullUrl"; text: "Show the full address" }
        SettingSwitch {
            key: "reduceMotion"
            text: "Reduce animations"
            description: "Linux has no system-wide setting Brisa can read, so this is set here."
        }

        Section { text: "Site content" }
        SettingSwitch { key: "javascript"; text: "JavaScript" }
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Text zoom"; color: Theme.onBg; Layout.fillWidth: true }
            Slider {
                id: zoom
                from: 50; to: 200; stepSize: 10
                Layout.preferredWidth: 140
                Accessible.name: "Text zoom"
                onMoved: Settings.set("textZoom", value)
            }
            Binding { target: zoom; property: "value"; value: Settings.values.textZoom }
            Label { text: Settings.values.textZoom + "%"; color: Theme.muted; Layout.preferredWidth: 40 }
        }

        Section { text: "About" }
        Label { text: "Brisa " + Browser.version; color: Theme.onBg }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: Theme.muted
            font.pixelSize: 12
            text: "Released under the MIT License. Built with Qt " + Browser.qtVersion
                + " and Chromium through Qt WebEngine. Brisa has no accounts, no analytics and no servers of its own."
        }
        Button { text: "Reset settings"; flat: true; onClicked: Settings.reset() }
        Item { Layout.preferredHeight: 16 }
    }
}
