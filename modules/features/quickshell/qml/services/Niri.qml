pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var _workspaces: []

    readonly property list<var> workspaces: _workspaces
    readonly property string focusedOutput: {
        for (let i = 0; i < _workspaces.length; ++i) {
            if (_workspaces[i].is_focused)
                return _workspaces[i].output;
        }
        return "";
    }
    readonly property ShellScreen focusedScreen: {
        const screens = Quickshell.screens;
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
        if (!line.startsWith('{"Workspace'))
            return;
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
}
