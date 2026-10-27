#pragma once

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QSaveFile>

// A JSON array kept in one file. Bookmarks and history are small, so every change rewrites the file.
class JsonList {
public:
    explicit JsonList(QString path) : path_(std::move(path)) {}

    QJsonArray load() const {
        QFile file(path_);
        if (!file.open(QIODevice::ReadOnly)) return {};
        return QJsonDocument::fromJson(file.readAll()).array();
    }

    void save(const QJsonArray &items) const {
        QSaveFile file(path_);
        if (!file.open(QIODevice::WriteOnly)) return;
        file.write(QJsonDocument(items).toJson(QJsonDocument::Compact));
        file.commit();
    }

private:
    QString path_;
};
