pragma ComponentBehavior: Bound

import QtQml

import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.notifs
import qs.modules.osd
import qs.modules.polkit
import qs.services

ShellRoot {
    Scope {

        Component.onCompleted: Lock;
    }

    Variants {
        model: Quickshell.screens

        Bar {}
    }

    OsdPanel {}

    NotifPopups {}

    PolkitDialog {}

    IpcHandler {
        target: "powerprofiles"

        function cycle() {
            Power.cycle();
        }
    }
}
