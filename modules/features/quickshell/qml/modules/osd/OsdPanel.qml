pragma ComponentBehavior: Bound

import QtQml
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

PanelWindow {
    id: root

    readonly property bool wanted: Osd.visible
    property real appear: 0
    property real outro: 0
    readonly property real outEase: outro < 0.5 ? 4 * outro * outro * outro : 1 - Math.pow(-2 * outro + 2, 3) / 2

    property string shownKind
    property string shownIcon
    property string shownLabel
    property real shownProgress: -1

    Binding {
        target: root
        property: "shownKind"
        value: Osd.kind
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownIcon"
        value: Osd.icon
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownLabel"
        value: Osd.label
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownProgress"
        value: Osd.progress
        when: root.wanted
    }

    readonly property color accent: shownKind === "volume" ? Theme.green
        : shownKind === "mic" ? Theme.purple
        : shownKind === "brightness" ? Theme.yellow
        : shownKind === "profile" ? Theme.blue
        : Theme.fg

    screen: Niri.focusedScreen
    color: "transparent"

    anchors.top: true

    margins.top: 8

    visible: wanted || appear > 0

    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-shell-osd"

    implicitWidth: 360
    implicitHeight: 96

    mask: Region {}

    onWantedChanged: {
        if (root.wanted) {
            exit.stop();

            if (root.outro > 0)
                back.restart();
            if (root.appear < 1)
                enter.restart();
        } else {
            enter.stop();
            exit.restart();
        }
    }

    NumberAnimation {
        id: enter

        target: root
        property: "appear"
        to: 1
        duration: 420
        easing.type: Easing.OutBack
        easing.overshoot: 1.6
    }

    NumberAnimation {
        id: back

        target: root
        property: "outro"
        to: 0
        duration: 160
    }

    SequentialAnimation {
        id: exit

        NumberAnimation {
            target: root
            property: "outro"
            from: 0
            to: 1
            duration: 450
        }
        ScriptAction {
            script: {
                root.appear = 0;
                root.outro = 0;
            }
        }
    }

    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        y: 12

        color: Theme.bg0
        radius: 10
        border.width: 1
        border.color: Theme.bg3

        opacity: Math.min(1, root.appear * 2) * (1 - root.outEase)
        transform: [
            Translate {
                y: (root.appear - 1) * 26 - 20 * root.outEase
            },
            Scale {
                origin.x: pill.width / 2
                origin.y: pill.height / 2
                xScale: 0.85 + 0.15 * root.appear
                yScale: xScale
            }
        ]

        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 14

        width: implicitWidth
        height: implicitHeight

        Behavior on width {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Row {
            id: row

            anchors.centerIn: parent
            spacing: 10

            Text {
                id: icon

                anchors.verticalCenter: parent.verticalCenter

                text: root.shownIcon
                color: root.accent
                font.family: Theme.fontFamily
                font.pixelSize: 14

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                onTextChanged: iconPop.restart()

                SequentialAnimation {
                    id: iconPop

                    NumberAnimation {
                        target: icon
                        property: "scale"
                        to: 1.45
                        duration: 90
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: icon
                        property: "scale"
                        to: 1
                        duration: 220
                        easing.type: Easing.OutBack
                    }
                }
            }

            Rectangle {
                id: track

                anchors.verticalCenter: parent.verticalCenter

                visible: root.shownProgress >= 0
                width: 140
                height: 6
                radius: 3
                color: Theme.bg3

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.shownProgress))
                    height: parent.height
                    radius: 3
                    color: root.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: root.shownLabel
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
