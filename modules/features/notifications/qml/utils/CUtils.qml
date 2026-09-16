pragma Singleton

import QtQuick
import Quickshell

Singleton {
    function clamp(value: real, min: real, max: real): real {
        return Math.max(min, Math.min(value, max));
    }
}
