import QtQuick
import Quickshell
import qs.modules.notifications
import qs.services

ShellRoot {
    Scope {
        Component.onCompleted: {
            Notifs;
            Niri;
        }
    }

    Variants {
        model: Quickshell.screens

        Popup {}
    }
}
