pragma ComponentBehavior: Bound

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // 0..100; keeps the last valid value while the sysfs file is unreadable
    readonly property real percentage: brightness >= 0 && max > 0
        ? Math.max(0, Math.min(100, Math.round(brightness / max * 100)))
        : 0

    property int brightness: -1
    property int max: -1

    // After a brightness key press the niri binding calls `ipc call brightness poke`,
    // which polls fast for a moment so the OSD tracks the change immediately.
    property bool fast: false

    function poke(): void {
        fast = true;
        fastStop.restart();
        currentView.reload();
    }

    function parseBrightness(text: string): int {
        const n = parseInt(text, 10);
        return isNaN(n) || n < 0 ? brightness : n;
    }

    // inotify on sysfs is unreliable: poll with a Timer instead of trusting watchChanges
    IpcHandler {
        target: "brightness"

        function poke(): void {
            root.poke();
        }
    }

    FileView {
        id: maxView

        path: "/sys/class/backlight/intel_backlight/max_brightness"
        watchChanges: false

        onLoaded: root.max = root.parseBrightness(text())
    }

    FileView {
        id: currentView

        path: "/sys/class/backlight/intel_backlight/brightness"
        watchChanges: true
        // Tiny sysfs file: read it synchronously instead of via a worker thread.
        blockLoading: true

        onLoaded: root.brightness = root.parseBrightness(text())
    }

    Timer {
        id: fastStop

        interval: 1200

        onTriggered: root.fast = false
    }

    Timer {
        interval: root.fast ? 25 : 500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: currentView.reload()
    }
}
