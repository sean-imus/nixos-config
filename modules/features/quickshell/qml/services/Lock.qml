pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.config

// Session lock: ext-session-lock via WlSessionLock, auth via PAM service
// "quickshell-lock" (NixOS: security.pam.services."quickshell-lock").
// Fallback if the shell dies while locked: run `swaylock` from a TTY.
Singleton {
    id: root

    function lockNow() {
        entry = "";
        lock.locked = true;
    }

    // Shared entry text so every output's field stays in sync.
    property string entry

    readonly property bool showEntry: pam.responseRequired && !pam.messageIsError

    function submit() {
        if (!lock.locked || !pam.responseRequired)
            return;
        pam.respond(entry);
        entry = "";
    }

    function cancelAuth() {
        pam.abort();
        entry = "";
        pam.start();
    }

    function lock() {
        lockNow();
    }

    PamContext {
        id: pam

        config: "quickshell-lock"
        user: Quickshell.env("USER")

        onCompleted: result => {
            if (result === PamResult.Success) {
                lock.unlock();
                entry = "";
            } else {
                // Failed / MaxTries: start a fresh conversation.
                entry = "";
                pam.start();
            }
        }

        onError: {
            entry = "";
            pam.start();
        }
    }

    WlSessionLock {
        id: lock

        locked: false

        onLockedChanged: {
            if (lock.locked) {
                entry = "";
                pam.start();
            } else {
                pam.abort();
            }
        }

        WlSessionLockSurface {
            id: surface

            color: Theme.bg0


            SystemClock {
                id: clock

                precision: SystemClock.Minutes
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
                    anchors.horizontalCenter: parent.horizontalCenter

                    width: 300
                    height: 44
                    radius: 10
                    color: Theme.bg1
                    border.width: 1
                    border.color: entryField.activeFocus ? Theme.green : Theme.bg3

                    TextField {
                        id: entryField

                        anchors.fill: parent
                        anchors.margins: 10

                        text: lock.entry
                        onTextChanged: lock.entry = text
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        placeholderText: lock.showEntry ? (pam.message || "Enter password") : ""
                        placeholderTextColor: Theme.grey0
                        background: null
                        enabled: lock.locked && lock.showEntry

                        onAccepted: lock.submit()
                        Keys.onEscapePressed: lock.cancelAuth()

                        Component.onCompleted: {
                            if (lock.locked)
                                forceActiveFocus();
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: pam.message !== "" && pam.messageIsError
                    text: visible ? pam.message : ""
                    color: Theme.red
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    visible: !pam.active || !pam.responseRequired
                    text: "Press Enter after typing your password"
                    color: Theme.grey0
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                }
            }

            Component.onCompleted: {
                if (lock.locked)
                    entryField.forceActiveFocus();
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            lock.locked = true;
        }
    }
}
