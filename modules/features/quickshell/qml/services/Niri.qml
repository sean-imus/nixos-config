pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Tracks niri compositor state via a single long-lived `niri msg -j event-stream`.
Singleton {
    id: root

    // Backing state; replaced whole on each event so readonly bindings re-evaluate.
    property var _workspaces: []
    property var _windowsMap: ({})
    property var _focusedWindowId: null // window id or null when nothing focused
    property bool _overviewOpen: false
    property var _keyboardLayouts: ({
            "names": [],
            "current_idx": 0
        })

    readonly property list<var> workspaces: _workspaces
    readonly property var windowsMap: _windowsMap
    readonly property var activeWindow: _focusedWindowId === null ? null : (_windowsMap[_focusedWindowId] ?? null)
    readonly property bool overviewOpen: _overviewOpen
    readonly property string keyboardLayout: _keyboardLayouts.names[_keyboardLayouts.current_idx] ?? ""
    readonly property string focusedOutput: {
        for (let i = 0; i < _workspaces.length; ++i) {
            if (_workspaces[i].is_focused)
                return _workspaces[i].output;
        }
        return "";
    }
    readonly property ShellScreen focusedScreen: {
        const screens = Quickshell.screens; // notifying: re-evaluates on screensChanged
        for (let i = 0; i < screens.length; ++i) {
            if (screens[i].name === focusedOutput)
                return screens[i];
        }
        return screens.length ? screens[0] : null;
    }

    Process {
        id: eventStream

        command: ["niri", "msg", "-j", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: line => root.handleLine(line)
        }

        onExited: restartTimer.restart()
    }

    Timer {
        id: restartTimer

        interval: 1000
        onTriggered: eventStream.running = true
    }

    function handleLine(line) {
        let event;
        try {
            event = JSON.parse(line);
        } catch (e) {
            return;
        }
        for (const type in event) {
            const data = event[type];
            switch (type) {
            case "WorkspacesChanged":
                root._workspaces = data.workspaces;
                break;
            case "WorkspaceActivated":
                root.applyWorkspaceActivated(data.id, data.focused);
                break;
            case "WorkspaceUrgencyChanged":
                root.applyWorkspaceUrgency(data.id, data.urgency);
                break;
            case "WindowsChanged":
                root.replaceWindows(data.windows);
                break;
            case "WindowOpenedOrChanged":
                root.upsertWindow(data.window);
                break;
            case "WindowClosed":
                root.removeWindow(data.id);
                break;
            case "WindowFocusChanged":
                root._focusedWindowId = data.id ?? null;
                break;
            case "OverviewOpenedOrClosed":
                root._overviewOpen = data.is_open;
                break;
            case "KeyboardLayoutsChanged":
                root._keyboardLayouts = data.keyboard_layouts;
                break;
            default:
                break; // unknown event: ignore
            }
        }
    }

    function applyWorkspaceActivated(id, focused) {
        const activated = root._workspaces.find(w => w.id === id);
        const output = activated ? activated.output : "";
        root._workspaces = root._workspaces.map(w => {
            const copy = Object.assign({}, w);
            if (copy.id === id) {
                copy.is_focused = focused;
                copy.is_active = true;
            } else {
                copy.is_focused = false;
                if (copy.output === output)
                    copy.is_active = false;
            }
            return copy;
        });
    }

    function applyWorkspaceUrgency(id, urgency) {
        root._workspaces = root._workspaces.map(w => {
            if (w.id !== id)
                return w;
            const copy = Object.assign({}, w);
            copy.is_urgent = urgency;
            return copy;
        });
    }

    function replaceWindows(list) {
        const map = {};
        for (let i = 0; i < list.length; ++i)
            root.insertWindow(map, list[i]);
        root._windowsMap = map;
    }

    function upsertWindow(win) {
        const map = Object.assign({}, root._windowsMap);
        root.insertWindow(map, win);
        root._windowsMap = map;
    }

    function removeWindow(id) {
        const map = Object.assign({}, root._windowsMap);
        delete map[id];
        root._windowsMap = map;
    }

    function insertWindow(map, win) {
        map[win.id] = {
            "id": win.id,
            "title": win.title,
            "app_id": win.app_id,
            "workspace_id": win.workspace_id,
            "is_focused": win.is_focused
        };
    }
}
