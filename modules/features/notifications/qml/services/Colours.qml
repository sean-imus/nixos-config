pragma Singleton

import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property bool light: false

    // Surfaces stay slightly translucent so the compositor blur behind the
    // layer shows through; 1.0 disables transparency entirely.
    readonly property var transparency: ({
            enabled: true,
            base: 0.85,
            layers: 0.82
        })

    readonly property Palette palette: Palette {}
    readonly property TPalette tPalette: TPalette {}

    function blend(a: color, b: color, t: real): color {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    function layer(c: color, layer: var): color {
        if (!transparency.enabled)
            return c;

        return layer === 0 ? Qt.alpha(c, transparency.base) : Qt.alpha(c, transparency.layers);
    }

    component Palette: QtObject {
        readonly property color m3surface: Theme.bg0
        readonly property color m3onSurface: Theme.fg
        readonly property color m3surfaceContainer: Theme.bg1
        readonly property color m3surfaceContainerHighest: Theme.bg3
        readonly property color m3onSurfaceVariant: Theme.grey2
        readonly property color m3primary: Theme.green
        readonly property color m3onPrimary: Theme.bg0
        readonly property color m3secondary: Theme.aqua
        readonly property color m3onSecondary: Theme.bg0
        readonly property color m3secondaryContainer: root.blend(Theme.bg2, Theme.red, 0.35)
        readonly property color m3onSecondaryContainer: Theme.fg
        readonly property color m3tertiary: Theme.blue
        readonly property color m3onTertiary: Theme.bg0
        readonly property color m3error: Theme.red
        readonly property color m3onError: Theme.bg0
        readonly property color m3shadow: Qt.rgba(0, 0, 0, 1)
    }

    component TPalette: QtObject {
        readonly property color m3surfaceContainer: root.layer(root.palette.m3surfaceContainer)
    }
}
