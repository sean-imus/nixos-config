pragma ComponentBehavior: Bound

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Claude plan usage (5-hour window), cached by the Claude Code statusLine script
// in $XDG_RUNTIME_DIR/claude-usage.json (see features/claude-code/README.md).
// The file only refreshes while a Claude Code session is running.
Singleton {
    id: root

    // 0..100, or -1 when the file does not exist (no session since boot).
    // A window whose reset time has passed counts as 0: usage restarts from zero.
    readonly property int percent: {
        if (!fiveHour)
            return -1;
        if (clock.date.getTime() / 1000 >= fiveHour.resets_at)
            return 0;
        return Math.max(0, Math.min(100, Math.round(fiveHour.used_percentage)));
    }

    property var fiveHour: null // { used_percentage, resets_at } or null

    function parse(text: string): void {
        try {
            const data = JSON.parse(text);
            const w = data.five_hour;
            fiveHour = w && typeof w.used_percentage === "number" && typeof w.resets_at === "number" ? w : null;
        } catch (e) {
            // Keep the previous value: the file may be mid-write.
        }
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    // The file is replaced by rename, which inotify watches miss: poll instead.
    FileView {
        id: view

        path: Quickshell.env("XDG_RUNTIME_DIR") + "/claude-usage.json"
        watchChanges: false
        blockLoading: true
        printErrors: false // the file is absent until the first session after boot

        onLoaded: root.parse(text())
        onLoadFailed: root.fiveHour = null
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: view.reload()
    }
}
