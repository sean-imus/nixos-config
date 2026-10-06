pragma ComponentBehavior: Bound

import QtQml
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

    // An authentication request is pending. The window itself stays mapped until
    // the exit animation has played out.
    readonly property bool wanted: root.flow !== null && !root.flow.isCompleted && !root.flow.isCancelled
    // 0..1 progress of the appear animation.
    property real appear: 0
    // 0..1 progress of the exit: a calm fade and drift up, like the lock screen.
    property real outro: 0
    readonly property real outEase: outro < 0.5 ? 4 * outro * outro * outro : 1 - Math.pow(-2 * outro + 2, 3) / 2

    // The flow becomes null the instant a request ends. These copies freeze at
    // that moment so the card keeps its text through the exit animation instead
    // of emptying while it is still fading.
    property string shownMessage
    property string shownIdentity
    property string shownPrompt
    property string shownStatus
    property bool shownStatusError
    property bool shownVisibleInput

    Binding {
        target: root
        property: "shownMessage"
        value: root.flow ? root.flow.message : ""
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownIdentity"
        value: root.flow && root.flow.selectedIdentity ? root.flow.selectedIdentity.string : ""
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownPrompt"
        value: root.flow ? root.flow.inputPrompt : ""
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownStatus"
        value: root.flow ? root.flow.supplementaryMessage : ""
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownStatusError"
        value: root.flow ? root.flow.supplementaryIsError : false
        when: root.wanted
    }

    Binding {
        target: root
        property: "shownVisibleInput"
        value: root.flow ? root.flow.responseVisible : false
        when: root.wanted
    }

    // Password sent, waiting for PAM's verdict (it delays after a failure).
    property bool checking
    // Last attempt failed; cleared when typing resumes.
    property bool failed
    // Bumped on every failure to trigger the shake.
    property int failures

    visible: wanted || appear > 0
    color: "transparent"
    screen: Niri.focusedScreen

    // The surface is taller than the card so the rise on appear and the drift up
    // on exit have room to play instead of being clipped by the window edge.
    readonly property int cardHeight: 196
    implicitWidth: 380
    implicitHeight: cardHeight + 112

    // Only the card takes pointer input, not the transparent margin around it.
    mask: Region {
        item: card
    }

    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-shell-polkit"

    // Scale of the card at the current animation progress.
    readonly property real cardScale: 0.88 + 0.12 * root.appear
    // Let go of the keyboard as soon as the request is over, not after the fade.
    WlrLayershell.keyboardFocus: root.wanted ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onWantedChanged: {
        if (root.wanted) {
            field.text = "";
            field.forceActiveFocus();
            root.checking = false;
            root.failed = false;
            exitAnim.stop();
            root.outro = 0;
            enterAnim.restart();
        } else {
            enterAnim.stop();
            exitAnim.restart();
        }
    }

    NumberAnimation {
        id: enterAnim

        target: root
        property: "appear"
        to: 1
        duration: 480
        easing.type: Easing.OutBack
        easing.overshoot: 1.4
    }

    SequentialAnimation {
        id: exitAnim

        NumberAnimation {
            target: root
            property: "outro"
            from: 0
            to: 1
            duration: 500
        }
        ScriptAction {
            script: {
                root.appear = 0;
                root.outro = 0;
            }
        }
    }

    onFailuresChanged: shake.restart()

    onFlowChanged: {
        // A null flow means the request just ended: leave the card as it is.
        if (root.flow === null)
            return;
        field.text = "";
        root.checking = false;
        root.failed = false;
        dotSalt = Math.floor(Math.random() * 1000);
    }

    function submit() {
        if (!root.flow || root.checking || field.text.length === 0)
            return;
        // Keep the dots on screen (dimmed) until PAM answers.
        root.checking = true;
        root.failed = false;
        root.flow.submit(field.text);
    }

    Shortcut {
        sequences: ["Escape"]
        enabled: root.wanted
        onActivated: root.flow.cancelAuthenticationRequest()
    }

    Connections {
        target: root.flow

        function onAuthenticationFailed() {
            // The flow stays alive with a fresh session; shake, flag the error,
            // clear the stale password and keep the dialog open.
            root.checking = false;
            root.failed = true;
            root.failures++;
            root.dotSalt++;
            field.text = "";
            field.forceActiveFocus();
        }
    }

    Rectangle {
        id: card

        anchors.centerIn: parent
        width: root.implicitWidth
        height: root.cardHeight
        radius: 12
        color: Theme.bg0

        // Rises and grows into place on appear; fades and drifts up on exit.
        opacity: Math.min(1, root.appear * 1.8) * (1 - root.outEase)
        transform: [
            Translate {
                y: (1 - root.appear) * 28 - 48 * root.outEase
            },
            Scale {
                origin.x: card.width / 2
                origin.y: card.height / 2
                xScale: root.cardScale
                yScale: xScale
            }
        ]

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                Layout.fillWidth: true

                text: root.shownMessage
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true

                text: root.shownIdentity
                color: Theme.grey1
                font.family: Theme.fontFamily
                font.pixelSize: 10
            }

            Text {
                Layout.fillWidth: true

                text: root.shownPrompt
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

                readOnly: root.checking
                onTextChanged: if (text.length > 0)
                    root.failed = false

                transform: Translate {
                    id: shift
                }

                SequentialAnimation {
                    id: shake

                    NumberAnimation {
                        target: shift
                        property: "x"
                        to: -10
                        duration: 50
                    }
                    NumberAnimation {
                        target: shift
                        property: "x"
                        to: 10
                        duration: 80
                    }
                    NumberAnimation {
                        target: shift
                        property: "x"
                        to: -6
                        duration: 70
                    }
                    NumberAnimation {
                        target: shift
                        property: "x"
                        to: 0
                        duration: 50
                    }
                }

                echoMode: root.shownVisibleInput ? TextInput.Normal : TextInput.Password
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
                    border.width: 1
                    border.color: root.failed ? Theme.red : "transparent"

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
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
                    // Dimmed while PAM is checking.
                    opacity: root.checking ? 0.45 : 1
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }
                    }
                }
            }

            // Status slot, always present so the layout never jumps.
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 14

                text: root.failed ? "Incorrect password" : root.checking ? "Checking…" : root.shownStatus
                color: root.failed || root.shownStatusError ? Theme.red : Theme.grey1
                horizontalAlignment: Text.AlignHCenter
                font.family: Theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
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
