import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    // The window stays mapped (1px tall when idle) on the focused output so the
    // list can lay out; hiding it at height 0 would keep the delegates from ever
    // being created.
    visible: Niri.focusedOutput === modelData.name
    implicitWidth: Tokens.sizes.notifs.width
    implicitHeight: Math.max(1, content.implicitHeight)
    color: "transparent"
    mask: content.implicitHeight > 0 ? fullRegion : emptyRegion

    anchors.top: true
    anchors.right: true
    margins.top: Tokens.spacing.small
    margins.right: Tokens.spacing.small
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "caelestia-notifs"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Region {
        id: fullRegion

        item: content
    }

    Region {
        id: emptyRegion
    }

    Content {
        id: content

        anchors.fill: parent
    }
}
