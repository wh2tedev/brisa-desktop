#pragma once

#include "blocklist.h"

#include <QMutex>
#include <QSet>
#include <QStringList>
#include <QWebEngineUrlRequestInterceptor>

#include <atomic>
#include <memory>

// Settings the request path reads. Requests are intercepted on the IO thread, so everything here is thread safe.
class FilterState {
public:
    brisa::Blocklist blocklist;  // filled before any profile is used, read-only afterwards

    std::atomic<int> level{1};  // 0 off, 1 standard, 2 strict
    std::atomic<bool> sendPrivacySignals{true};
    std::atomic<bool> blockThirdPartyCookies{true};

    void setExceptions(const QStringList &hosts);
    bool isException(const QString &host) const;

private:
    mutable QMutex mutex_;
    QSet<QString> exceptions_;
};

class RequestInterceptor : public QWebEngineUrlRequestInterceptor {
    Q_OBJECT

public:
    RequestInterceptor(std::shared_ptr<FilterState> state, QObject *parent = nullptr);

    void interceptRequest(QWebEngineUrlRequestInfo &info) override;

signals:
    // Host of the page that made the blocked request.
    void blocked(const QString &pageHost);

private:
    std::shared_ptr<FilterState> state_;
};
