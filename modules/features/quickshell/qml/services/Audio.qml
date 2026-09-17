pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sinkNode: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property PwNode sourceNode: Pipewire.ready ? Pipewire.defaultAudioSource : null

    readonly property bool sinkReady: sinkNode !== null && sinkNode.ready && sinkNode.audio !== null
    readonly property bool sourceReady: sourceNode !== null && sourceNode.ready && sourceNode.audio !== null

    // 0..1; 0 when no device is available yet
    readonly property real sinkVolume: sinkReady ? sinkNode.audio.volume : 0
    readonly property bool sinkMuted: sinkReady ? sinkNode.audio.muted : false
    readonly property real sourceVolume: sourceReady ? sourceNode.audio.volume : 0
    readonly property bool sourceMuted: sourceReady ? sourceNode.audio.muted : false

    function toggleSinkMuted(): void {
        if (sinkReady)
            sinkNode.audio.muted = !sinkNode.audio.muted;
    }

    function toggleSourceMuted(): void {
        if (sourceReady)
            sourceNode.audio.muted = !sourceNode.audio.muted;
    }

    function changeSinkVolume(step: real): void {
        if (sinkReady)
            sinkNode.audio.volume = Math.max(0, Math.min(1, sinkNode.audio.volume + step));
    }

    function changeSourceVolume(step: real): void {
        if (sourceReady)
            sourceNode.audio.volume = Math.max(0, Math.min(1, sourceNode.audio.volume + step));
    }
}
