pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config

Singleton {
    readonly property var current: {
        const profile = PowerProfiles.profile;
        if (profile === PowerProfile.Performance && PowerProfiles.hasPerformanceProfile)
            return {
                "label": "PERF high",
                "color": Theme.red,
                "icon": ""
            };
        if (profile === PowerProfile.PowerSaver)
            return {
                "label": "PERF low",
                "color": Theme.green,
                "icon": ""
            };
        return {
            "label": "PERF med",
            "color": Theme.yellow,
            "icon": ""
        };
    }

    function cycle(): void {
        const order = PowerProfiles.hasPerformanceProfile
                ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
                : [PowerProfile.PowerSaver, PowerProfile.Balanced];
        const i = order.indexOf(PowerProfiles.profile);
        PowerProfiles.profile = order[(i + 1) % order.length];
    }
}
