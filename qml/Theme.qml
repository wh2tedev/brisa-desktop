pragma Singleton
import QtQuick
import Brisa

QtObject {
    readonly property var prefs: Settings.values

    readonly property bool dark: prefs.theme === "dark"
        || (prefs.theme === "system" && Application.styleHints.colorScheme === Qt.ColorScheme.Dark)
    readonly property bool black: dark && prefs.pureBlack

    readonly property color bg: dark ? (black ? "#000000" : "#202124") : "#FFFFFF"
    readonly property color toolbar: dark ? (black ? "#0A0A0A" : "#35363A") : "#F1F3F4"
    readonly property color field: dark ? (black ? "#1C1C1E" : "#202124") : "#FFFFFF"
    readonly property color popup: dark ? (black ? "#121212" : "#2B2C2F") : "#FFFFFF"
    readonly property color divider: dark ? (black ? "#2A2A2C" : "#3C4043") : "#DADCE0"
    readonly property color onBg: dark ? "#E8EAED" : "#202124"
    readonly property color muted: dark ? "#9AA0A6" : "#5F6368"
    readonly property color onAccent: dark ? "#202124" : "#FFFFFF"
    readonly property color warning: dark ? "#F28B82" : "#D93025"

    readonly property var accents: ({
        blue:   { dark: "#8AB4F8", light: "#1A73E8" },
        green:  { dark: "#81C995", light: "#188038" },
        purple: { dark: "#C58AF9", light: "#8430CE" },
        orange: { dark: "#FDA45F", light: "#C25E00" },
        pink:   { dark: "#FF8BCB", light: "#D01884" },
        teal:   { dark: "#4DB6AC", light: "#00796B" },
        red:    { dark: "#F28B82", light: "#D93025" }
    })
    readonly property color accent: (accents[prefs.accent] || accents.blue)[dark ? "dark" : "light"]

    // Motion. Zero durations when the user asks for reduced motion.
    readonly property bool reduceMotion: prefs.reduceMotion
    readonly property int fast: reduceMotion ? 0 : 140
    readonly property int slow: reduceMotion ? 0 : 240
    readonly property var decelerate: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var accelerate: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]

    readonly property int radius: 12
    readonly property int controlHeight: 40

    function errorColors() {
        return { bg: bg, fg: onBg, muted: muted, accent: accent, onAccent: onAccent }
    }
}
