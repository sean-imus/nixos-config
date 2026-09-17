pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

PanelWindow {
    id: root

    screen: Niri.focusedScreen
    color: "transparent"

    anchors.top: true

    margins.top: 8

    visible: pill.opacity > 0

    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-shell-osd"

    readonly property color accent: Osd.kind === "volume" ? Theme.green
        : Osd.kind === "mic" ? Theme.purple
        : Osd.kind === "brightness" ? Theme.yellow
        : Osd.kind === "profile" ? Theme.blue
        : Theme.fg

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    // content-sized pill; invisible while the label is empty
    Rectangle {
        id: pill

        anchors.centerIn: parent

        readonly property bool shown: Osd.visible && Osd.label !== ""

        opacity: shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 14

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: Osd.icon
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 14
            }

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter

                visible: Osd.progress >= 0
                width: 140
                height: 6
                radius: 3
                color: Theme.bg3

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, Osd.progress))
                    height: parent.height
                    radius: 3
                    color: root.accent
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: Osd.label
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
