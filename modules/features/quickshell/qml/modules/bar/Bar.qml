pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import qs.config
import qs.services

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
        id: clockText

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 6

        text: Qt.formatDateTime(clock.date, "HH:mm dd.MM.yyyy")
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: 11
    }

    // Workspaces for this screen, left after the clock.
    Row {
        anchors.left: clockText.right
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        spacing: 4

        Repeater {
            model: {
                const list = Array.from(Niri.workspaces).filter(w => w.output === root.modelData.name);
                list.sort((a, b) => a.idx - b.idx);
                return list;
            }

            delegate: MouseArea {
                id: wsItem

                required property var modelData

                implicitWidth: wsText.implicitWidth
                implicitHeight: wsText.implicitHeight
                cursorShape: Qt.PointingHandCursor

                onClicked: Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(wsItem.modelData.idx)])

                Text {
                    id: wsText

                    anchors.fill: parent

                    text: wsItem.modelData.idx
                    color: wsItem.modelData.is_focused ? Theme.fg : wsItem.modelData.is_urgent ? Theme.red : wsItem.modelData.is_active ? Theme.grey2 : Theme.grey1
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }

    // Status indicators, waybar order: profile, mic, vol, battery.
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        spacing: 6

        MouseArea {
            id: profileItem

            readonly property var info: {
                const hasPerf = PowerProfiles.hasPerformanceProfile;
                const profile = PowerProfiles.profile;
                if (profile === PowerProfile.Performance)
                    return hasPerf ? ["PERF high", Theme.red] : ["PERF med", Theme.yellow];
                if (profile === PowerProfile.Balanced)
                    return ["PERF med", Theme.yellow];
                return ["PERF low", Theme.green];
            }

            implicitWidth: profileText.implicitWidth
            implicitHeight: profileText.implicitHeight
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                const order = PowerProfiles.hasPerformanceProfile
                        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
                        : [PowerProfile.PowerSaver, PowerProfile.Balanced];
                const i = order.indexOf(PowerProfiles.profile);
                PowerProfiles.profile = order[(i + 1) % order.length];
            }

            Text {
                id: profileText

                anchors.centerIn: parent

                text: profileItem.info[0]
                color: profileItem.info[1]
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: micItem

            implicitWidth: micText.implicitWidth
            implicitHeight: micText.implicitHeight
            cursorShape: Qt.PointingHandCursor

            onClicked: Audio.toggleSourceMuted()

            WheelHandler {
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        Audio.changeSourceVolume(0.05);
                    else if (wheel.angleDelta.y < 0)
                        Audio.changeSourceVolume(-0.05);
                    wheel.accepted = true;
                }
            }

            Text {
                id: micText

                anchors.centerIn: parent

                visible: Audio.sourceReady
                text: Audio.sourceMuted ? "MIC muted" : "MIC " + Math.round(Audio.sourceVolume * 100) + "%"
                color: Audio.sourceMuted ? Theme.grey0 : Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }

        MouseArea {
            id: volItem

            implicitWidth: volText.implicitWidth
            implicitHeight: volText.implicitHeight
            cursorShape: Qt.PointingHandCursor

            onClicked: Audio.toggleSinkMuted()

            WheelHandler {
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0)
                        Audio.changeSinkVolume(0.05);
                    else if (wheel.angleDelta.y < 0)
                        Audio.changeSinkVolume(-0.05);
                    wheel.accepted = true;
                }
            }

            Text {
                id: volText

                anchors.centerIn: parent
                visible: Audio.sinkReady
                text: Audio.sinkMuted ? "VOL muted" : "VOL " + Math.round(Audio.sinkVolume * 100) + "%"
                color: Audio.sinkMuted ? Theme.grey0 : Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }
        }

        Text {
            id: batText

            readonly property real pct: {
                const dev = UPower.displayDevice;
                return dev ? Math.max(0, Math.min(100, Math.round(dev.percentage * 100))) : 0;
            }

            visible: UPower.displayDevice !== null
            text: visible ? "BAT " + pct + "%" : ""
            color: {
                const dev = UPower.displayDevice;
                if (!dev)
                    return Theme.fg;
                if (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged)
                    return Theme.green;
                if (dev.state === UPowerDeviceState.Discharging && pct <= 15)
                    return Theme.red;
                return Theme.fg;
            }
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}
