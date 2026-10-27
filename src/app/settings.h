#pragma once

#include <QObject>
#include <QSettings>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class QJSEngine;
class QQmlEngine;

// All user preferences. QML reads Settings.values.<key> and writes with Settings.set(key, value).
class Settings : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QVariantMap values READ values NOTIFY changed)

public:
    static Settings *instance();
    static Settings *create(QQmlEngine *, QJSEngine *);

    QVariantMap values() const { return values_; }
    Q_INVOKABLE void set(const QString &key, const QVariant &value);
    Q_INVOKABLE void reset();

    bool boolean(const QString &key) const { return values_.value(key).toBool(); }
    int integer(const QString &key) const { return values_.value(key).toInt(); }
    QString string(const QString &key) const { return values_.value(key).toString(); }
    QStringList list(const QString &key) const { return values_.value(key).toStringList(); }

signals:
    void changed();

private:
    Settings();
    static QVariantMap defaults();

    QSettings store_;
    QVariantMap values_;
};
