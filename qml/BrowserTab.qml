import QtQuick
import QtWebEngine
import Brisa

// One tab. The page lives only inside the WebEngineView; nothing from the backend is exposed to it.
Item {
    id: tab

    property bool isPrivate: false
    property var opener: null           // tab to return to when this one closes
    property string upgradedFrom: ""    // http address we tried over https first
    property bool showingError: false
    property int blocked: 0
    property bool active: false

    opacity: active ? 1 : 0
    visible: opacity > 0
    enabled: active
    Behavior on opacity {
        NumberAnimation { duration: Theme.slow; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.standard }
    }

    property alias view: view
    readonly property string title: view.title
    readonly property string pageUrl: view.url.toString()
    readonly property bool loading: view.loading
    readonly property int progress: view.loadProgress
    readonly property string host: Browser.hostOf(pageUrl)

    signal closeRequested()
    signal popupRequested(var request)
    signal fullScreenChanged(bool on)

    function load(text) {
        view.url = Browser.resolve(text)
    }

    function failureTitle(domain) {
        switch (domain) {
        case WebEngineView.CertificateErrorDomain: return "This site's certificate can't be trusted"
        case WebEngineView.DnsErrorDomain: return "Can't find this site"
        case WebEngineView.ConnectionErrorDomain: return "Can't reach this site"
        default: return "This page didn't load"
        }
    }

    function handleFailure(info) {
        const aborted = info.errorCode === -3  // user navigation, downloads and requests we ignored
        if (aborted || info.errorDomain === WebEngineView.HttpErrorDomain) return

        // HTTPS first: fall back to HTTP only when the connection itself failed, never on certificate errors
        if (upgradedFrom !== "" && info.errorDomain === WebEngineView.ConnectionErrorDomain
                && Browser.scheme(info.url.toString()) === "https") {
            const target = upgradedFrom
            upgradedFrom = ""
            Browser.allowHttp(Browser.hostOf(target))
            view.url = target
            return
        }

        showingError = true
        view.loadHtml(Browser.errorPage(info.url.toString(), failureTitle(info.errorDomain),
                                        info.errorString, Theme.errorColors()), info.url)
    }

    Connections {
        target: Browser
        function onBlockedChanged(pageHost) {
            if (pageHost === tab.host) tab.blocked = Browser.blockedCount(pageHost)
        }
    }

    WebEngineView {
        id: view
        anchors.fill: parent
        profile: tab.isPrivate ? Browser.privateProfile : Browser.persistentProfile
        zoomFactor: Settings.values.textZoom / 100

        settings.javascriptEnabled: Settings.values.javascript
        settings.javascriptCanOpenWindows: true  // popups are still ignored unless the user triggered them
        settings.javascriptCanAccessClipboard: false
        settings.localContentCanAccessRemoteUrls: false
        settings.localContentCanAccessFileUrls: false
        settings.allowRunningInsecureContent: false
        settings.allowGeolocationOnInsecureOrigins: false
        settings.webRTCPublicInterfacesOnly: true
        settings.dnsPrefetchEnabled: false
        settings.errorPageEnabled: false
        settings.pluginsEnabled: false
        settings.screenCaptureEnabled: false

        onNavigationRequested: function(request) {
            if (!request.isMainFrame) return
            const target = request.url.toString()
            const targetHost = Browser.hostOf(target)

            if (upgradedFrom !== "" && targetHost !== Browser.hostOf(upgradedFrom)) upgradedFrom = ""
            if (!Settings.values.httpsFirst) return

            const secure = Browser.upgraded(target)
            if (secure === "") return
            request.action = WebEngineNavigationRequest.IgnoreRequest
            upgradedFrom = target
            Qt.callLater(function() { view.url = secure })
        }

        onLoadingChanged: function(info) {
            switch (info.status) {
            case WebEngineView.LoadStartedStatus:
                Browser.resetBlocked(Browser.hostOf(info.url.toString()))
                tab.blocked = 0
                break
            case WebEngineView.LoadSucceededStatus:
                if (showingError) {
                    showingError = false
                } else if (!tab.isPrivate && Browser.scheme(tab.pageUrl).startsWith("http")) {
                    Browser.recordVisit(tab.pageUrl, view.title)
                }
                break
            case WebEngineView.LoadFailedStatus:
                tab.handleFailure(info)
                break
            }
        }

        // Certificate errors are never bypassable.
        onCertificateError: function(error) { error.rejectCertificate() }

        // Per-site permission prompts come later; until then everything is denied.
        onPermissionRequested: function(permission) { permission.deny() }

        onNewWindowRequested: function(request) {
            if (request.userInitiated) tab.popupRequested(request)
        }

        onWindowCloseRequested: tab.closeRequested()

        onFullScreenRequested: function(request) {
            tab.fullScreenChanged(request.toggleOn)
            request.accept()
        }
    }
}
