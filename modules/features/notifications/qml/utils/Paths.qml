pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string home: Quickshell.env("HOME")
    readonly property string state: `${Quickshell.env("XDG_STATE_HOME") || `${home}/.local/state`}/caelestia-notifs`
}
