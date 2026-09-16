import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    color: "transparent"
    implicitHeight: 18
    exclusiveZone: implicitHeight

    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "qs-shell-bar"

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 6

        text: Qt.formatDateTime(clock.date, "HH:mm dd.MM.yyyy")
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: 11
    }
}
