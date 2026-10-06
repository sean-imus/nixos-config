pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.config
import qs.services

PanelWindow {
    id: root

    screen: Niri.focusedScreen
    color: "transparent"
    implicitWidth: 400
    implicitHeight: column.height + 16
    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.right: true

    margins.top: 8
    margins.right: 8

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-shell-notifs"

    visible: Notifs.popups.length > 0

    Column {
        id: column

        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 8

        Repeater {
            model: Notifs.popups

            NotifCard {
                required property var modelData

                popup: modelData
            }
        }
    }

    component NotifCard: Item {
        id: card

        required property var popup

        readonly property bool critical: popup.urgency === NotificationUrgency.Critical
        // Stable accent per app, red for critical.
        readonly property color accent: {
            if (critical)
                return Theme.red;
            const tints = [Theme.green, Theme.aqua, Theme.blue, Theme.purple, Theme.yellow, Theme.orange];
            let hash = 0;
            for (const ch of popup.appName)
                hash = (hash * 31 + ch.charCodeAt(0)) % 997;
            return tints[hash % tints.length];
        }

        // 0 -> 1 on appear: slides in from the right while fading up.
        property real enter: 0

        width: 400
        height: body.y + body.height + (bar.visible ? 22 : 16)
        opacity: Math.min(1, enter * 1.6)
        transform: Translate {
            x: (1 - card.enter) * 70
        }

        NumberAnimation on enter {
            from: 0
            to: 1
            duration: 420
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }

        Rectangle {
            id: surface

            anchors.fill: parent
            radius: 16
            // Translucent so the compositor blur shows through.
            color: Qt.alpha(Theme.bg0, 0.86)
            border.width: 1
            border.color: card.critical ? Theme.red : Qt.alpha(Theme.fg, 0.08)
        }

        // Accent stripe down the left edge.
        Rectangle {
            x: 0
            y: 18
            width: 3
            height: card.height - 36
            radius: 2
            color: card.accent
        }

        MouseArea {
            id: hover

            anchors.fill: parent
            hoverEnabled: true

            onClicked: Notifs.dismiss(card.popup)
        }

        // Initial of the app in a tinted badge.
        Rectangle {
            id: badge

            x: 16
            y: 14
            width: 36
            height: 36
            radius: 12
            color: Qt.alpha(card.accent, 0.18)

            Text {
                anchors.centerIn: parent
                text: card.popup.appName.length > 0 ? card.popup.appName.charAt(0).toUpperCase() : "!"
                color: card.accent
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.bold: true
            }
        }

        Column {
            id: head

            x: badge.x + badge.width + 12
            y: 14
            width: card.width - x - 40
            spacing: 2

            Text {
                width: parent.width
                text: card.popup.appName.toUpperCase()
                color: Theme.grey0
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.letterSpacing: 1.2
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: card.popup.summary
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }
        }

        // Close affordance, only while hovered.
        Text {
            x: card.width - width - 16
            y: 16
            text: "✕"
            color: hover.containsMouse ? Theme.fg : Theme.grey0
            opacity: hover.containsMouse ? 1 : 0
            font.family: Theme.fontFamily
            font.pixelSize: 11

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        Column {
            id: body

            x: head.x
            y: Math.max(head.y + head.height, badge.y + badge.height) + 6
            width: card.width - x - 16
            spacing: 8

            Text {
                visible: text.length > 0
                width: parent.width
                text: card.popup.body
                color: Theme.grey2
                font.family: Theme.fontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 4
            }

            Row {
                visible: card.popup.actions.length > 0
                spacing: 6

                Repeater {
                    model: card.popup.actions

                    Rectangle {
                        id: actionButton

                        required property var modelData

                        implicitWidth: actionText.implicitWidth + 20
                        implicitHeight: actionText.implicitHeight + 10
                        radius: height / 2
                        color: actionArea.containsMouse ? Qt.alpha(card.accent, 0.3) : Qt.alpha(card.accent, 0.14)

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }
                        }

                        Text {
                            id: actionText

                            anchors.centerIn: parent
                            text: actionButton.modelData ? actionButton.modelData.label : ""
                            color: card.accent
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }

                        MouseArea {
                            id: actionArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: Notifs.invokeAction(card.popup, actionButton.modelData.identifier)
                        }
                    }
                }
            }
        }

        // Countdown to auto-dismiss; absent for notifications that never expire.
        Rectangle {
            id: bar

            property real remaining: 1

            visible: card.popup.timeout > 0
            x: 16
            y: card.height - 10
            width: (card.width - 32) * remaining
            height: 2
            radius: 1
            color: Qt.alpha(card.accent, 0.55)

            NumberAnimation on remaining {
                from: 1
                to: 0
                duration: Math.max(1, card.popup.timeout)
                running: card.popup.timeout > 0
            }
        }
    }
}
