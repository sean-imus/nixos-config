pragma ComponentBehavior: Bound

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services

Singleton {
    id: root

    // state machine driving the OSD panel; armed prevents initial bindings from flashing
    property bool armed: false

    readonly property bool visible: label !== ""
    readonly property string kind: _kind
    readonly property string icon: _icon
    readonly property string label: _label
    // 0..1, or -1 when the kind has no bar (e.g. profile, muted volume)
    readonly property real progress: _progress
    readonly property color accent: _accent

    property string _kind: ""
    property string _icon: ""
    property string _label: ""
    property real _progress: -1
    property color _accent: Theme.fg

    // Armed 1s after construction so initial state loads (pipewire connect,
    // first sysfs poll, power-profiles init) never flash the OSD.
    Timer {
        interval: 1000
        running: true

        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer

        interval: 1500

        onTriggered: root.clear()
    }

    function show(kind: string, icon: string, label: string, progress: real, accentColor): void {
        root._kind = kind;
        root._icon = icon;
        root._label = label;
        root._progress = progress;
        root._accent = accentColor ?? Theme.fg;
        hideTimer.restart();
    }

    function clear(): void {
        root._kind = "";
        root._icon = "";
        root._label = "";
        root._progress = -1;
        hideTimer.stop();
    }

    Connections {
        target: Audio

        function onSinkVolumeChanged(): void {
            if (!root.armed)
                return;
            const pct = Math.round(Audio.sinkVolume * 100);
            if (Audio.sinkMuted) {
                root.show("volume", "\uf6a9", "VOL muted", -1, null);
            } else {
                root.show("volume", "\uf028", `VOL ${pct}%`, Audio.sinkVolume, null);
            }
        }

        function onSinkMutedChanged(): void {
            if (!root.armed)
                return;
            if (Audio.sinkMuted) {
                root.show("volume", "\uf6a9", "VOL muted", -1, null);
            } else {
                const pct = Math.round(Audio.sinkVolume * 100);
                root.show("volume", "\uf028", `VOL ${pct}%`, Audio.sinkVolume, null);
            }
        }

        function onSourceMutedChanged(): void {
            if (!root.armed)
                return;
            if (Audio.sourceMuted) {
                root.show("mic", "\uf131", "MIC muted", -1, null);
            } else {
                const pct = Math.round(Audio.sourceVolume * 100);
                root.show("mic", "\uf130", `MIC ${pct}%`, Audio.sourceVolume, null);
            }
        }
    }

    Connections {
        target: Brightness

        function onPercentageChanged(): void {
            if (!root.armed)
                return;
            const pct = Math.round(Brightness.percentage);
            root.show("brightness", "\uf185", `BRI ${pct}%`, pct / 100, null);
        }
    }

    Connections {
        target: PowerProfiles

        function onProfileChanged(): void {
            if (!root.armed)
                return;
            switch (PowerProfiles.profile) {
            case PowerProfile.Performance:
                root.show("profile", "\uf0e4", "PERF high", -1, null);
                break;
            case PowerProfile.PowerSaver:
                root.show("profile", "\uf06c", "PERF low", -1, null);
                break;
            default:
                root.show("profile", "\uf24e", "PERF med", -1, null);
                break;
            }
        }
    }
}
