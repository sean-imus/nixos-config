pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Pipewire.defaultAudioSink is briefly undefined during defaults-metadata
    // updates, and untracked nodes have no audio data, so every access below
    // is exception-safe: one throw kills the binding for good and every
    // consumer permanently reads undefined.
    readonly property var sinkNode: Pipewire.ready ? Pipewire.defaultAudioSink : null
    readonly property var sourceNode: Pipewire.ready ? Pipewire.defaultAudioSource : null

    // Untracked nodes never bind: audio stays null and volumes stay empty.
    // The tracker follows the default nodes when they change.
    PwObjectTracker {
        objects: [root.sinkNode, root.sourceNode]
    }

    function readNode(node): var {
        try {
            if (!node || !node.ready || !node.audio)
                return {
                    "ready": false,
                    "volume": 0,
                    "muted": false
                };
            const volume = node.audio.volume;
            if (typeof volume !== "number" || !Number.isFinite(volume))
                return {
                    "ready": false,
                    "volume": 0,
                    "muted": node.audio.muted === true
                };
            return {
                "ready": true,
                "volume": volume,
                "muted": node.audio.muted === true
            };
        } catch (e) {
            return {
                "ready": false,
                "volume": 0,
                "muted": false
            };
        }
    }

    readonly property var sinkState: readNode(root.sinkNode)
    readonly property var sourceState: readNode(root.sourceNode)

    readonly property bool sinkReady: sinkState.ready
    readonly property real sinkVolume: sinkState.volume
    readonly property bool sinkMuted: sinkState.muted

    readonly property bool sourceReady: sourceState.ready
    readonly property real sourceVolume: sourceState.volume
    readonly property bool sourceMuted: sourceState.muted

    function toggleSinkMuted(): void {
        if (!root.sinkReady)
            return;
        try {
            root.sinkNode.audio.muted = !root.sinkNode.audio.muted;
        } catch (e) {
        }
    }

    function toggleSourceMuted(): void {
        if (!root.sourceReady)
            return;
        try {
            root.sourceNode.audio.muted = !root.sourceNode.audio.muted;
        } catch (e) {
        }
    }

    function changeSinkVolume(step: real): void {
        if (!root.sinkReady)
            return;
        try {
            root.sinkNode.audio.volume = Math.max(0, Math.min(1, root.sinkNode.audio.volume + step));
        } catch (e) {
        }
    }

    function changeSourceVolume(step: real): void {
        if (!root.sourceReady)
            return;
        try {
            root.sourceNode.audio.volume = Math.max(0, Math.min(1, root.sourceNode.audio.volume + step));
        } catch (e) {
        }
    }
}
