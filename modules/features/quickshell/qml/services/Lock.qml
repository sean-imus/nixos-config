pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config

// Session lock: ext-session-lock via WlSessionLock, auth via PAM service
// "quickshell-lock" (NixOS: security.pam.services."quickshell-lock").
// Fallback if the shell dies while locked: run `swaylock` from a TTY.
//
// QS_LOCK_TEST=1 makes the lock release itself after 30 s, so a broken lock
// screen cannot trap the session while developing. Unset in normal use.
Singleton {
    id: root

    readonly property bool testMode: Quickshell.env("QS_LOCK_TEST") === "1"

    // Shared state so every output's surface stays in sync.
    property string entry
    // Password submitted, waiting for PAM's verdict (it delays after a failure).
    property bool checking
    // Last attempt failed; cleared on the next keypress.
    property bool failed
    // Bumped on every failure to trigger the shake animation.
    property int failures

    function lock() {
        entry = "";
        checking = false;
        failed = false;
        sessionLock.locked = true;
        // Not driven by lockStateChanged: that only fires once the compositor
        // confirms the lock.
        pam.start();
        if (testMode)
            testUnlock.restart();
    }

    function submit() {
        if (!pam.responseRequired || entry.length === 0)
            return;
        checking = true;
        pam.respond(entry);
        entry = "";
    }

    function cancelAuth() {
        pam.abort();
        entry = "";
        checking = false;
        failed = false;
        pam.start();
    }

    function type(event) {
        if (checking)
            return;
        failed = false;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            submit();
        else if (event.key === Qt.Key_Escape)
            cancelAuth();
        else if (event.key === Qt.Key_Backspace)
            entry = entry.slice(0, -1);
        else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && !(event.modifiers & Qt.ControlModifier))
            entry += event.text;
    }

    PamContext {
        id: pam

        config: "quickshell-lock"
        user: Quickshell.env("USER")

        onCompleted: result => {
            root.entry = "";
            root.checking = false;
            if (result === PamResult.Success) {
                sessionLock.locked = false;
            } else {
                root.failed = true;
                root.failures++;
                pam.start();
            }
        }

        onError: {
            root.entry = "";
            root.checking = false;
            pam.start();
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        // The NOTIFY signal of `locked` is lockStateChanged (no lockedChanged).
        onLockStateChanged: {
            if (!sessionLock.locked) {
                pam.abort();
                testUnlock.stop();
            }
        }

        WlSessionLockSurface {
            color: Theme.bg0

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

            // Raw key capture instead of a TextField: no enabled/focus states to
            // get out of sync with PAM.
            Item {
                id: keys

                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    root.type(event);
                    event.accepted = true;
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 64
                    font.bold: true
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
                    color: Theme.grey2
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }

                Item {
                    width: 1
                    height: 8
                }

                Rectangle {
                    id: box

                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 300
                    height: 44
                    radius: 10
                    color: Theme.bg1
                    border.width: 1
                    border.color: root.failed ? Theme.red : keys.activeFocus ? Theme.green : Theme.bg3

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

                    Connections {
                        target: root

                        function onFailuresChanged() {
                            shake.restart();
                        }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.margins: 10

                        verticalAlignment: Text.AlignVCenter
                        text: root.entry.length > 0 ? "●".repeat(root.entry.length) : root.checking ? "Checking…" : "Password"
                        color: root.entry.length > 0 ? Theme.fg : Theme.grey0
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        elide: Text.ElideLeft
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    opacity: root.failed ? 1 : 0
                    text: "Incorrect password"
                    color: Theme.red
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }

    Timer {
        id: testUnlock

        interval: 30000
        onTriggered: sessionLock.locked = false
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }
}
