pragma ComponentBehavior: Bound

import QtQml

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.modules.bar
import qs.modules.notifs
import qs.modules.osd
import qs.modules.polkit
import qs.services

ShellRoot {
    Scope {
        // Instantiate services with startup side effects (IpcHandlers).
        Component.onCompleted: Lock;
    }

    Variants {
        model: Quickshell.screens

        Bar {}
    }

    // Popup surfaces target the focused output (services/Niri).
    OsdPanel {}

    NotifPopups {}

    PolkitDialog {}

    IpcHandler {
        target: "powerprofiles"

        function cycle() {
            const profiles = PowerProfiles.hasPerformanceProfile
                    ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
                    : [PowerProfile.PowerSaver, PowerProfile.Balanced];
            const idx = profiles.indexOf(PowerProfiles.profile);
            PowerProfiles.profile = profiles[(idx + 1) % profiles.length];
        }
    }
}
