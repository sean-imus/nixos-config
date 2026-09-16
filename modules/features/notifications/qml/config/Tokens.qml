pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property var rounding: ({
            extraSmall: 4,
            small: 8,
            medium: 12,
            large: 16,
            extraLarge: 28,
            full: 1000
        })
    readonly property var spacing: ({
            extraSmall: 4,
            small: 8,
            medium: 12,
            large: 16,
            extraLarge: 28
        })
    readonly property var padding: ({
            extraSmall: 4,
            small: 8,
            medium: 12,
            large: 16,
            extraLarge: 28
        })
    readonly property var sizes: ({
            notifs: ({
                    width: 430,
                    image: 42,
                    badge: 20
                })
        })
    readonly property var anim: ({
            durations: ({
                    small: 200,
                    normal: 400,
                    large: 600,
                    extraLarge: 1000,
                    expressiveFastSpatial: 350,
                    expressiveDefaultSpatial: 500,
                    expressiveSlowSpatial: 650,
                    expressiveFastEffects: 150,
                    expressiveDefaultEffects: 200,
                    expressiveSlowEffects: 300
                }),
            emphasized: Easing.OutCubic,
            emphasizedAccel: Easing.InCubic,
            emphasizedDecel: Easing.OutQuint,
            standard: Easing.OutQuart,
            standardAccel: Easing.InCubic,
            standardDecel: Easing.OutQuart,
            expressiveFastSpatial: Easing.OutBack,
            expressiveDefaultSpatial: Easing.OutBack,
            expressiveSlowSpatial: Easing.OutBack,
            expressiveFastEffects: Easing.OutCubic,
            expressiveDefaultEffects: Easing.OutCubic,
            expressiveSlowEffects: Easing.OutCubic
        })
    readonly property var font: ({
            body: ({
                    large: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 16
                        }),
                    medium: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 14
                        }),
                    small: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 12
                        })
                }),
            label: ({
                    large: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 14,
                            weight: Font.Medium
                        }),
                    medium: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 12,
                            weight: Font.Medium
                        }),
                    small: Qt.font({
                            family: Theme.fontFamily,
                            pixelSize: 11,
                            weight: Font.Medium
                        })
                }),
            icon: ({
                    extraLarge: Qt.font({
                            family: "Material Symbols Rounded",
                            pixelSize: 36
                        }),
                    large: Qt.font({
                            family: "Material Symbols Rounded",
                            pixelSize: 24
                        }),
                    medium: Qt.font({
                            family: "Material Symbols Rounded",
                            pixelSize: 18
                        }),
                    small: Qt.font({
                            family: "Material Symbols Rounded",
                            pixelSize: 15
                        })
                })
        })
}
