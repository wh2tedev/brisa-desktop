#pragma once

#include "json_list.h"
#include "request_interceptor.h"

#include <QHash>
#include <QObject>
#include <QSet>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

#include <memory>

class QJSEngine;
class QQmlEngine;
class QQuickWebEngineProfile;

// Backend for the browser UI. QML talks to this; web pages never get access to it.
class Browser : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QObject *persistentProfile READ persistentProfile CONSTANT)
    Q_PROPERTY(QObject *privateProfile READ privateProfile CONSTANT)
    Q_PROPERTY(bool cookieFilterActive READ cookieFilterActive CONSTANT)
    Q_PROPERTY(QVariantList engines READ engines CONSTANT)
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString qtVersion READ qtVersion CONSTANT)

public:
    static Browser *instance();
    static Browser *create(QQmlEngine *, QJSEngine *);

    QObject *persistentProfile() const;
    QObject *privateProfile() const;
    bool cookieFilterActive() const { return cookieFilterActive_; }
    QVariantList engines() const;
    QString version() const;
    QString qtVersion() const;

    // Address bar and navigation
    Q_INVOKABLE QString resolve(const QString &typed) const;
    Q_INVOKABLE QString homeUrl() const;
    Q_INVOKABLE QString hostOf(const QString &url) const;
    Q_INVOKABLE QString scheme(const QString &url) const;
    Q_INVOKABLE QString upgraded(const QString &url) const;
    Q_INVOKABLE void allowHttp(const QString &host);
    Q_INVOKABLE QVariantList suggestions(const QString &typed) const;
    Q_INVOKABLE QString errorPage(const QString &url, const QString &title, const QString &message,
                                  const QVariantMap &colors) const;

    // Tracker blocking
    Q_INVOKABLE int blockedCount(const QString &host) const;
    Q_INVOKABLE void resetBlocked(const QString &host);
    Q_INVOKABLE bool siteAllowed(const QString &host) const;
    Q_INVOKABLE void setSiteAllowed(const QString &host, bool allowed);

    // Bookmarks and history
    Q_INVOKABLE bool isBookmarked(const QString &url) const;
    Q_INVOKABLE void toggleBookmark(const QString &url, const QString &title);
    Q_INVOKABLE void removeBookmark(const QString &url);
    Q_INVOKABLE QVariantList bookmarks() const;
    Q_INVOKABLE void recordVisit(const QString &url, const QString &title);
    Q_INVOKABLE void removeVisit(const QString &url);
    Q_INVOKABLE QVariantList history() const;
    Q_INVOKABLE void clearHistory();

    // Downloads and data
    Q_INVOKABLE bool isDangerousFile(const QString &fileName) const;
    Q_INVOKABLE QString localPath(const QUrl &url) const;
    Q_INVOKABLE QUrl fileUrl(const QString &path) const;
    Q_INVOKABLE void deleteFile(const QString &path) const;
    Q_INVOKABLE void clearData(bool history, bool cookies, bool cache);

signals:
    void blockedChanged(const QString &pageHost);

private:
    Browser();
    void applySettings();
    void configure(QQuickWebEngineProfile *profile, std::shared_ptr<FilterState> state);
    void loadBlocklists();
    QVariantList searchLibrary(const JsonList &list, const QString &needle, int limit) const;

    std::shared_ptr<FilterState> filters_;
    QQuickWebEngineProfile *persistent_ = nullptr;
    QQuickWebEngineProfile *private_ = nullptr;
    bool cookieFilterActive_ = false;

    JsonList bookmarkStore_;
    JsonList historyStore_;
    QSet<QString> httpAllowed_;
    QHash<QString, int> blockedCounts_;
};
