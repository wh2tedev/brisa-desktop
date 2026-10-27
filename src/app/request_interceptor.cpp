#include "request_interceptor.h"

#include <QWebEngineUrlRequestInfo>

namespace {

bool isSameSite(const QString &host, const QString &pageHost) {
    return host == pageHost || host.endsWith('.' + pageHost) || pageHost.endsWith('.' + host);
}

}  // namespace

void FilterState::setExceptions(const QStringList &hosts) {
    QMutexLocker lock(&mutex_);
    exceptions_ = QSet<QString>(hosts.begin(), hosts.end());
}

bool FilterState::isException(const QString &host) const {
    QMutexLocker lock(&mutex_);
    QString current = host;
    while (!current.isEmpty()) {
        if (exceptions_.contains(current)) return true;
        const int dot = current.indexOf('.');
        if (dot < 0) return false;
        current = current.mid(dot + 1);
    }
    return false;
}

RequestInterceptor::RequestInterceptor(std::shared_ptr<FilterState> state, QObject *parent)
    : QWebEngineUrlRequestInterceptor(parent), state_(std::move(state)) {}

void RequestInterceptor::interceptRequest(QWebEngineUrlRequestInfo &info) {
    if (state_->sendPrivacySignals) {
        info.setHttpHeader("DNT", "1");
        info.setHttpHeader("Sec-GPC", "1");
    }

    const int level = state_->level;
    if (level == 0) return;
    if (info.resourceType() == QWebEngineUrlRequestInfo::ResourceTypeMainFrame) return;

    const QUrl requestUrl = info.requestUrl();
    if (requestUrl.scheme() != "http" && requestUrl.scheme() != "https") return;

    const QString host = requestUrl.host().toLower();
    const QString pageHost = info.firstPartyUrl().host().toLower();
    if (pageHost.isEmpty() || isSameSite(host, pageHost)) return;
    if (state_->isException(pageHost)) return;
    if (!state_->blocklist.isBlocked(host.toStdString(), level == 2)) return;

    info.block(true);
    emit blocked(pageHost);
}
