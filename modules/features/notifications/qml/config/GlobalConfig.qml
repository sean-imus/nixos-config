pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var notifs: ({
            expire: true,
            fullscreen: false,
            defaultExpireTimeout: 8000,
            fullscreenExpireTimeout: 2000,
            clearThreshold: 0.3,
            expandThreshold: 20,
            actionOnClick: false,
            openExpanded: false
        })
}
