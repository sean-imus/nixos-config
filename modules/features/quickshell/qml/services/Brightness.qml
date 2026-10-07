pragma ComponentBehavior: Bound

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property real percentage: brightness >= 0 && max > 0
        ? Math.max(0, Math.min(100, Math.round(brightness / max * 100)))
        : 0

    property int brightness: -1
    property int max: -1

    property bool fast: false

    Component.onCompleted: currentView.reload()

    function poke(): void {
        fast = true;
        fastStop.restart();
        currentView.reload();
    }

    function parseBrightness(text: string): int {
        const n = parseInt(text, 10);
        return isNaN(n) || n < 0 ? brightness : n;
    }

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
        watchChanges: false
        blockLoading: true

        onLoaded: root.brightness = root.parseBrightness(text())
    }

    Timer {
        id: fastStop

        interval: 1200

        onTriggered: root.fast = false
    }

    Timer {
        interval: 25
        running: root.fast
        repeat: true

        onTriggered: currentView.reload()
    }
}
