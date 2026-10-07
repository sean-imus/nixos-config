pragma ComponentBehavior: Bound

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int percent: {
        if (!fiveHour)
            return -1;
        if (clock.date.getTime() / 1000 >= fiveHour.resets_at)
            return 0;
        return Math.max(0, Math.min(100, Math.round(fiveHour.used_percentage)));
    }

    property var fiveHour: null

    function parse(text: string): void {
        try {
            const data = JSON.parse(text);
            const w = data.five_hour;
            fiveHour = w && typeof w.used_percentage === "number" && typeof w.resets_at === "number" ? w : null;
        } catch (e) {

        }
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    FileView {
        id: view

        path: Quickshell.env("XDG_RUNTIME_DIR") + "/claude-usage.json"
        watchChanges: false
        blockLoading: true
        printErrors: false

        onLoaded: root.parse(text())
        onLoadFailed: root.fiveHour = null
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: view.reload()
    }
}
