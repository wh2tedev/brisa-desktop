#include "browser.h"

#include "search_engines.h"
#include "settings.h"
#include "urls.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJSEngine>
#include <QJsonObject>
#include <QQuickWebEngineProfile>
#include <QStandardPaths>
#include <QWebEngineCookieStore>

#include <type_traits>

namespace {

constexpr int kHistoryLimit = 5000;
constexpr int kSuggestionLimit = 7;

QString dataFile(const QString &name) {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + '/' + name;
}

QString readResource(const QString &path) {
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? QString::fromUtf8(file.readAll()) : QString();
}

QString normalizeHost(const QString &host) {
    QString h = host.toLower();
    if (h.startsWith("www.")) h.remove(0, 4);
    return h;
}

// Not every Qt build exposes the cookie store on the Quick profile, so detect it at compile time.
template <typename Profile>
auto installCookieFilter(Profile *profile, std::shared_ptr<FilterState> state, int)
    -> decltype(profile->cookieStore(), bool()) {
    profile->cookieStore()->setCookieFilter([state](const QWebEngineCookieStore::FilterRequest &request) {
        return !(state->blockThirdPartyCookies && request.thirdParty);
    });
    return true;
}

template <typename Profile>
bool installCookieFilter(Profile *, std::shared_ptr<FilterState>, long) {
    return false;
}

template <typename Profile>
auto deleteCookies(Profile *profile, int) -> decltype(profile->cookieStore(), void()) {
    profile->cookieStore()->deleteAllCookies();
}

template <typename Profile>
void deleteCookies(Profile *, long) {}

}  // namespace

Browser *Browser::instance() {
    static Browser browser;
    return &browser;
}

Browser *Browser::create(QQmlEngine *, QJSEngine *) {
    auto *browser = instance();
    QJSEngine::setObjectOwnership(browser, QJSEngine::CppOwnership);
    return browser;
}

Browser::Browser()
    : filters_(std::make_shared<FilterState>()),
      bookmarkStore_(dataFile("bookmarks.json")),
      historyStore_(dataFile("history.json")) {
    loadBlocklists();

    persistent_ = new QQuickWebEngineProfile(QStringLiteral("brisa"), this);
    persistent_->setPersistentCookiesPolicy(QQuickWebEngineProfile::ForcePersistentCookies);
    persistent_->setHttpCacheType(QQuickWebEngineProfile::DiskHttpCache);
    private_ = new QQuickWebEngineProfile(this);  // no storage name: off the record

    configure(persistent_, filters_);
    configure(private_, filters_);

    connect(Settings::instance(), &Settings::changed, this, &Browser::applySettings);
    applySettings();
}

void Browser::configure(QQuickWebEngineProfile *profile, std::shared_ptr<FilterState> state) {
    auto *interceptor = new RequestInterceptor(state, profile);
    profile->setUrlRequestInterceptor(interceptor);
    connect(interceptor, &RequestInterceptor::blocked, this, [this](const QString &pageHost) {
        ++blockedCounts_[pageHost];
        emit blockedChanged(pageHost);
    });

    cookieFilterActive_ = installCookieFilter(profile, state, 0);
    if (!cookieFilterActive_) {
        qWarning("Third-party cookie blocking is unavailable: this Qt build has no cookie store on Quick profiles.");
    }
}

void Browser::loadBlocklists() {
    filters_->blocklist.loadStandard(brisa::Blocklist::parse(readResource(":/brisa/blocklists/blocklist.txt").toStdString()));
    filters_->blocklist.loadStrict(
        brisa::Blocklist::parse(readResource(":/brisa/blocklists/blocklist_strict.txt").toStdString()));
}

void Browser::applySettings() {
    const auto *settings = Settings::instance();
    filters_->level = settings->integer("trackerLevel");
    filters_->sendPrivacySignals = settings->boolean("sendPrivacySignals");
    filters_->blockThirdPartyCookies = settings->boolean("blockThirdPartyCookies");
    filters_->setExceptions(settings->list("siteExceptions"));
}

QObject *Browser::persistentProfile() const { return persistent_; }
QObject *Browser::privateProfile() const { return private_; }

QVariantList Browser::engines() const {
    QVariantList list;
    for (const auto &engine : brisa::searchEngines()) {
        list.append(QVariantMap{{"key", QString::fromUtf8(engine.key.data(), engine.key.size())},
                                {"name", QString::fromUtf8(engine.name.data(), engine.name.size())}});
    }
    return list;
}

QString Browser::version() const { return QStringLiteral(BRISA_VERSION); }
QString Browser::qtVersion() const { return QString::fromLatin1(qVersion()); }

QString Browser::resolve(const QString &typed) const {
    const std::string engine = Settings::instance()->string("searchEngine").toStdString();
    const auto result = brisa::urls::resolve(typed.toStdString(), [&engine](const std::string &query) {
        return brisa::searchUrl(engine, query);
    });
    return QString::fromStdString(result);
}

QString Browser::homeUrl() const {
    const QString home = Settings::instance()->string("homepage").trimmed();
    return home.isEmpty() ? QStringLiteral("https://www.google.com") : resolve(home);
}

QString Browser::hostOf(const QString &url) const { return QUrl(url).host().toLower(); }
QString Browser::scheme(const QString &url) const { return QUrl(url).scheme().toLower(); }

QString Browser::upgraded(const QString &url) const {
    QUrl parsed(url);
    const QString host = parsed.host().toLower();
    const bool defaultPort = parsed.port() == -1 || parsed.port() == 80;
    if (parsed.scheme() != "http" || !defaultPort || host.isEmpty()) return {};
    if (brisa::urls::isPrivateHost(host.toStdString()) || httpAllowed_.contains(host)) return {};
    parsed.setScheme("https");
    parsed.setPort(-1);
    return parsed.toString();
}

void Browser::allowHttp(const QString &host) { httpAllowed_.insert(host.toLower()); }

QVariantList Browser::suggestions(const QString &typed) const {
    const QString text = typed.trimmed();
    if (text.isEmpty()) return {};

    const auto &engine = brisa::searchEngine(Settings::instance()->string("searchEngine").toStdString());
    QVariantList result;
    result.append(QVariantMap{{"kind", "search"},
                              {"title", "Search with " + QString::fromUtf8(engine.name.data(), engine.name.size())},
                              {"url", resolve(text)},
                              {"detail", text}});

    QSet<QString> seen;
    auto add = [&](const QVariantList &items, const QString &kind) {
        for (const auto &item : items) {
            const auto entry = item.toMap();
            const QString url = entry.value("url").toString();
            if (seen.contains(url) || result.size() > kSuggestionLimit) continue;
            seen.insert(url);
            result.append(QVariantMap{{"kind", kind},
                                      {"title", entry.value("title")},
                                      {"url", url},
                                      {"detail", hostOf(url)}});
        }
    };
    add(searchLibrary(bookmarkStore_, text, kSuggestionLimit), "bookmark");
    if (Settings::instance()->boolean("saveHistory")) add(searchLibrary(historyStore_, text, kSuggestionLimit), "history");
    return result;
}

QVariantList Browser::searchLibrary(const JsonList &list, const QString &needle, int limit) const {
    QVariantList matches;
    for (const auto &value : list.load()) {
        const QJsonObject entry = value.toObject();
        if (entry.value("url").toString().contains(needle, Qt::CaseInsensitive) ||
            entry.value("title").toString().contains(needle, Qt::CaseInsensitive)) {
            matches.append(entry.toVariantMap());
            if (matches.size() >= limit) break;
        }
    }
    return matches;
}

QString Browser::errorPage(const QString &url, const QString &title, const QString &message,
                           const QVariantMap &colors) const {
    QString html = readResource(":/brisa/error.html");
    const QMap<QString, QString> fields = {
        {"{{TITLE}}", title.toHtmlEscaped()},
        {"{{MESSAGE}}", message.toHtmlEscaped()},
        {"{{URL}}", QString::fromUtf8(QUrl(url).toEncoded()).toHtmlEscaped()},
        {"{{HOST}}", QUrl(url).host().toHtmlEscaped()},
        {"{{BG}}", colors.value("bg").toString()},
        {"{{FG}}", colors.value("fg").toString()},
        {"{{MUTED}}", colors.value("muted").toString()},
        {"{{ACCENT}}", colors.value("accent").toString()},
        {"{{ON_ACCENT}}", colors.value("onAccent").toString()},
    };
    for (auto it = fields.begin(); it != fields.end(); ++it) html.replace(it.key(), it.value());
    return html;
}

int Browser::blockedCount(const QString &host) const { return blockedCounts_.value(host.toLower()); }
void Browser::resetBlocked(const QString &host) {
    if (blockedCounts_.remove(host.toLower())) emit blockedChanged(host.toLower());
}

bool Browser::siteAllowed(const QString &host) const { return filters_->isException(normalizeHost(host)); }

void Browser::setSiteAllowed(const QString &host, bool allowed) {
    auto *settings = Settings::instance();
    QStringList hosts = settings->list("siteExceptions");
    const QString normalized = normalizeHost(host);
    if (normalized.isEmpty()) return;
    hosts.removeAll(normalized);
    if (allowed) hosts.append(normalized);
    hosts.sort();
    settings->set("siteExceptions", hosts);
}

bool Browser::isBookmarked(const QString &url) const {
    for (const auto &value : bookmarkStore_.load()) {
        if (value.toObject().value("url").toString() == url) return true;
    }
    return false;
}

void Browser::toggleBookmark(const QString &url, const QString &title) {
    if (url.isEmpty()) return;
    if (isBookmarked(url)) {
        removeBookmark(url);
        return;
    }
    QJsonArray items = bookmarkStore_.load();
    items.prepend(QJsonObject{{"url", url}, {"title", title.isEmpty() ? url : title}});
    bookmarkStore_.save(items);
}

void Browser::removeBookmark(const QString &url) {
    QJsonArray kept;
    for (const auto &value : bookmarkStore_.load()) {
        if (value.toObject().value("url").toString() != url) kept.append(value);
    }
    bookmarkStore_.save(kept);
}

QVariantList Browser::bookmarks() const { return bookmarkStore_.load().toVariantList(); }

void Browser::recordVisit(const QString &url, const QString &title) {
    if (!Settings::instance()->boolean("saveHistory")) return;
    QJsonArray items = historyStore_.load();
    if (!items.isEmpty() && items.first().toObject().value("url").toString() == url) items.removeFirst();
    items.prepend(QJsonObject{{"url", url}, {"title", title.isEmpty() ? url : title},
                              {"time", QDateTime::currentSecsSinceEpoch()}});
    while (items.size() > kHistoryLimit) items.removeLast();
    historyStore_.save(items);
}

void Browser::removeVisit(const QString &url) {
    QJsonArray kept;
    for (const auto &value : historyStore_.load()) {
        if (value.toObject().value("url").toString() != url) kept.append(value);
    }
    historyStore_.save(kept);
}

QVariantList Browser::history() const { return historyStore_.load().toVariantList(); }
void Browser::clearHistory() { historyStore_.save({}); }

bool Browser::isDangerousFile(const QString &fileName) const {
    static const QSet<QString> dangerous = {"apk", "exe", "msi", "bat", "cmd", "scr", "jar",
                                            "js",  "vbs", "ps1", "sh",  "lnk", "dmg"};
    return dangerous.contains(QFileInfo(fileName).suffix().toLower());
}

QString Browser::localPath(const QUrl &url) const { return url.toLocalFile(); }
QUrl Browser::fileUrl(const QString &path) const { return QUrl::fromLocalFile(path); }
void Browser::deleteFile(const QString &path) const { QFile::remove(path); }

void Browser::clearData(bool history, bool cookies, bool cache) {
    if (history) clearHistory();
    if (cookies) deleteCookies(persistent_, 0);
    if (cache) persistent_->clearHttpCache();
}
