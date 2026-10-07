pragma ComponentBehavior: Bound

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config
import qs.services

Singleton {
    id: root

    property bool armed: false

    readonly property bool visible: label !== ""
    readonly property string kind: _kind
    readonly property string icon: _icon
    readonly property string label: _label
    readonly property real progress: _progress

    property string _kind: ""
    property string _icon: ""
    property string _label: ""
    property real _progress: -1

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

    function show(kind: string, icon: string, label: string, progress: real): void {
        if (!armed)
            return;
        root._kind = kind;
        root._icon = icon;
        root._label = label;
        root._progress = progress;
        hideTimer.restart();
    }

    function showLevel(kind: string, mutedIcon: string, icon: string, volume: real, muted: bool): void {
        const name = kind === "mic" ? "MIC" : "VOL";
        if (muted)
            root.show(kind, mutedIcon, `${name} muted`, -1);
        else
            root.show(kind, icon, `${name} ${Math.round(volume * 100)}%`, volume);
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
            root.showLevel("volume", "", "", Audio.sinkVolume, Audio.sinkMuted);
        }

        function onSinkMutedChanged(): void {
            root.showLevel("volume", "", "", Audio.sinkVolume, Audio.sinkMuted);
        }

        function onSourceVolumeChanged(): void {
            root.showLevel("mic", "", "", Audio.sourceVolume, Audio.sourceMuted);
        }

        function onSourceMutedChanged(): void {
            root.showLevel("mic", "", "", Audio.sourceVolume, Audio.sourceMuted);
        }
    }

    Connections {
        target: Brightness

        function onPercentageChanged(): void {
            const pct = Math.round(Brightness.percentage);
            root.show("brightness", "", `BRI ${pct}%`, pct / 100);
        }
    }

    Connections {
        target: PowerProfiles

        function onProfileChanged(): void {
            root.show("profile", Power.current.icon, Power.current.label, -1);
        }
    }
}
