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

    component NotifCard: Rectangle {
        id: card

        required property var popup

        width: 400
        height: content.y + content.height + 10
        radius: 12
        color: Theme.bg0
        border.width: popup.urgency === NotificationUrgency.Critical ? 1 : 0
        border.color: Theme.red

        // Fade in on appear; dismissal is immediate.
        opacity: 0
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Component.onCompleted: card.opacity = 1

        MouseArea {
            anchors.fill: parent

            onClicked: Notifs.dismiss(card.popup)
        }

        Column {
            id: content

            x: 10
            y: 10
            width: card.width - 20
            spacing: 3

            Text {
                text: card.popup.appName
                color: Theme.grey0
                font.family: Theme.fontFamily
                font.pixelSize: 10
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: card.popup.summary
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: card.popup.body
                color: Theme.grey1
                font.family: Theme.fontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 5
                width: parent.width
            }

            Row {
                spacing: 6

                Repeater {
                    model: card.popup.actions

                    Rectangle {
                        id: actionButton

                        required property var modelData

                        implicitWidth: actionText.implicitWidth + 16
                        implicitHeight: actionText.implicitHeight + 8
                        radius: 6
                        color: actionArea.containsMouse ? Theme.bg3 : Theme.bg2

                        Text {
                            id: actionText

                            anchors.centerIn: parent
                            text: actionButton.modelData.label
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
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
    }
}
