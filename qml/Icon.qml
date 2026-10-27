import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property string path
    property color color: "white"
    property int size: 20

    implicitWidth: size
    implicitHeight: size

    Shape {
        width: 24
        height: 24
        scale: root.size / 24
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeWidth: -1
            fillRule: ShapePath.WindingFill
            PathSvg { path: root.path }
        }
    }
}
