pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    readonly property alias agent: agent
    readonly property AuthFlow flow: agent.flow

    PolkitAgent {
        id: agent
    }
}
