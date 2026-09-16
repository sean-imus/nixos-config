pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Niri 26.04's IPC exposes no fullscreen state, so popups are never
    // suppressed for fullscreen windows for now.
    readonly property bool fullscreen: false
    property string focusedOutput

    Process {
        id: query

        command: ["niri", "msg", "--json", "focused-output"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.focusedOutput = JSON.parse(text).name ?? "";
                } catch (e) {
                    root.focusedOutput = "";
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: query.running = true
    }
}
