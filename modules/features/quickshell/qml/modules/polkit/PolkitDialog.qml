pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Polkit
import qs.components
import qs.config
import qs.services

// Unanchored layer-shell surfaces are centered on both axes by the
// compositor, keeping the window content-sized instead of fullscreen.
PanelWindow {
    id: root

    readonly property AuthFlow flow: Polkit.flow
    // New symbol seed for each authentication request.
    property int dotSalt: Math.floor(Math.random() * 1000)

    visible: root.flow !== null && !root.flow.isCompleted && !root.flow.isCancelled
    color: "transparent"
    screen: Niri.focusedScreen

    implicitWidth: 380
    implicitHeight: 180

    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-shell-polkit"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: {
        if (root.visible) {
            field.text = "";
            field.forceActiveFocus();
        }
    }

    onFlowChanged: {
        field.text = "";
        dotSalt = Math.floor(Math.random() * 1000);
    }

    function submit() {
        if (!root.flow)
            return;
        root.flow.submit(field.text);
        field.text = "";
    }

    Shortcut {
        sequences: ["Escape"]
        enabled: root.visible && root.flow !== null
        onActivated: root.flow.cancelAuthenticationRequest()
    }

    Connections {
        target: root.flow

        function onAuthenticationFailed() {
            // The flow stays alive with a fresh session; clear the stale
            // password and keep the dialog open.
            field.text = "";
            field.forceActiveFocus();
        }
    }

    Rectangle {
        id: card

        anchors.fill: parent
        radius: 12
        color: Theme.bg0

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                Layout.fillWidth: true

                text: root.flow ? root.flow.message : ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true

                text: root.flow && root.flow.selectedIdentity ? root.flow.selectedIdentity.string : ""
                color: Theme.grey1
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }

            Text {
                Layout.fillWidth: true

                text: root.flow ? root.flow.inputPrompt : ""
                color: Theme.grey2
                font.family: Theme.fontFamily
                font.pixelSize: 11
            }

            TextField {
                id: field

                Layout.fillWidth: true

                readonly property bool hidden: echoMode === TextInput.Password

                // The symbols are drawn by SecretDots, so a caret would not follow
                // them (and rendered black); hide it for hidden input.
                cursorDelegate: hidden ? noCursor : null

                Component {
                    id: noCursor

                    Item {}
                }

                echoMode: root.flow && root.flow.responseVisible ? TextInput.Normal : TextInput.Password
                // Hidden input is drawn by SecretDots; the field only takes the keys.
                color: hidden ? "transparent" : Theme.fg
                selectionColor: hidden ? "transparent" : palette.highlight
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter

                font.family: Theme.fontFamily
                // Bigger, spaced dots for hidden input; normal size for visible text.
                font.pixelSize: hidden ? 20 : 11

                background: Rectangle {
                    radius: 6
                    color: Theme.bg2
                }

                onAccepted: root.submit()

                SecretDots {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8

                    visible: field.hidden
                    count: field.length
                    salt: root.dotSalt
                    pixelSize: 18
                }
            }

            Text {
                Layout.fillWidth: true

                visible: root.flow !== null && root.flow.supplementaryMessage !== ""
                text: root.flow ? root.flow.supplementaryMessage : ""
                color: root.flow && root.flow.supplementaryIsError ? Theme.red : Theme.grey1
                font.family: Theme.fontFamily
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight

                spacing: 8

                Button {
                    id: authButton

                    contentItem: Text {
                        text: authButton.text
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: authButton.hovered ? Theme.bg3 : Theme.bg2
                    }

                    text: "Authenticate"
                    onClicked: root.submit()
                }

                Button {
                    id: cancelButton

                    contentItem: Text {
                        text: cancelButton.text
                        color: Theme.grey1
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 6
                        color: cancelButton.hovered ? Theme.bg3 : Theme.bg1
                    }

                    text: "Cancel"
                    onClicked: if (root.flow)
                        root.flow.cancelAuthenticationRequest()
                }
            }
        }
    }
}
