#include "browser.h"
#include "settings.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QtWebEngineQuick/QtWebEngineQuick>

int main(int argc, char *argv[]) {
    QCoreApplication::setOrganizationName("Brisa");
    QCoreApplication::setApplicationName("Brisa");
    QCoreApplication::setApplicationVersion(BRISA_VERSION);

    QtWebEngineQuick::initialize();
    QGuiApplication app(argc, argv);
    app.setDesktopFileName("brisa");
    QQuickStyle::setStyle("Material");

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [] {
        if (Settings::instance()->boolean("clearOnExit")) Browser::instance()->clearData(true, true, true);
    });

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, [] { QCoreApplication::exit(1); },
                     Qt::QueuedConnection);
    engine.loadFromModule("Brisa", "Main");
    return app.exec();
}
