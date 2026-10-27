#include "settings.h"

#include <QJSEngine>
#include <QStandardPaths>

Settings *Settings::instance() {
    static Settings settings;
    return &settings;
}

Settings *Settings::create(QQmlEngine *, QJSEngine *) {
    auto *settings = instance();
    QJSEngine::setObjectOwnership(settings, QJSEngine::CppOwnership);
    return settings;
}

QVariantMap Settings::defaults() {
    return {
        {"searchEngine", "google"},
        {"homepage", ""},
        {"restoreTabs", true},
        {"openTabs", QStringList()},
        {"httpsFirst", true},
        {"trackerLevel", 1},  // 0 off, 1 standard, 2 strict
        {"siteExceptions", QStringList()},
        {"blockThirdPartyCookies", true},
        {"sendPrivacySignals", true},
        {"saveHistory", true},
        {"clearOnExit", false},
        {"javascript", true},
        {"textZoom", 100},
        {"confirmDownloads", true},
        {"downloadDir", QStandardPaths::writableLocation(QStandardPaths::DownloadLocation)},
        {"theme", "dark"},
        {"pureBlack", false},
        {"accent", "blue"},
        {"fullUrl", false},
        {"reduceMotion", false},
    };
}

Settings::Settings() : store_(QSettings::IniFormat, QSettings::UserScope, "Brisa", "Brisa") {
    values_ = defaults();
    for (auto it = values_.begin(); it != values_.end(); ++it) {
        const QVariant saved = store_.value(it.key());
        if (!saved.isValid()) continue;
        // QSettings returns strings for everything it read from an INI file
        QVariant converted = saved;
        if (converted.convert(it.value().metaType())) it.value() = converted;
    }
}

void Settings::set(const QString &key, const QVariant &value) {
    if (!values_.contains(key) || values_.value(key) == value) return;
    values_[key] = value;
    store_.setValue(key, value);
    emit changed();
}

void Settings::reset() {
    store_.clear();
    values_ = defaults();
    emit changed();
}
