import QtQuick
import qs.config

// Hidden-input display. Every typed character is a dot; a new one first springs
// in as a big random symbol (cycling glyphs and palette colours), holds a beat,
// then morphs into a small dot. The strip is centred with an animated width, so
// existing dots glide aside as characters are added or removed, and removed
// dots shrink away. Symbols are a pure function of (index, salt, tick), so
// several instances given the same salt (one per monitor) agree on the result.
Item {
    id: root

    property int count
    property int salt
    property color color: Theme.fg
    property int pixelSize: 20

    readonly property real dotSize: pixelSize * 0.6
    // Wide enough that the big entrance symbols never touch their neighbours.
    readonly property real cellWidth: pixelSize * 1.15

    // Nerd Font (Font Awesome range) codepoints: star, heart, leaf, bolt, sun, moon,
    // bell, cog, cloud, paw, fire, wand, flag, bookmark, badge, tree, drop, bulb,
    // gamepad, bomb, rocket, plane. Drawn with Theme.symbolFont so every glyph
    // exists and has the same width.
    readonly property var glyphs: [0xf005, 0xf004, 0xf06c, 0xf0e7, 0xf185, 0xf186, 0xf0f3, 0xf013, 0xf0c2, 0xf1b0, 0xf06d, 0xf0d0, 0xf024, 0xf02e, 0xf0a3, 0xf1bb, 0xf043, 0xf0eb, 0xf11b, 0xf1e2, 0xf135, 0xf1d8]
    readonly property var tints: [Theme.green, Theme.aqua, Theme.blue, Theme.purple, Theme.yellow, Theme.orange, Theme.red]

    function rand(index, seed) {
        return Math.abs(Math.sin((index + 1) * 12.9898 + seed * 78.233) * 43758.5453) % 1;
    }

    function symbolAt(index, seed) {
        return String.fromCodePoint(glyphs[Math.floor(rand(index, seed) * glyphs.length)]);
    }

    function tintAt(index, seed) {
        return tints[Math.floor(rand(index + 3, seed) * tints.length)];
    }

    implicitHeight: pixelSize * 1.6

    // A real model, not an integer: an integer model rebuilds every delegate when
    // the count changes, which replayed every dot's animation on each keypress.
    ListModel {
        id: items
    }

    function sync() {
        while (items.count < count)
            items.append({
                "n": items.count
            });
        while (items.count > count)
            items.remove(items.count - 1);
    }

    onCountChanged: sync()
    Component.onCompleted: sync()

    ListView {
        id: strip

        anchors.centerIn: parent
        width: root.count * root.cellWidth
        height: root.implicitHeight

        orientation: ListView.Horizontal
        interactive: false
        model: items

        // Shrink instead of overflowing when the password is long.
        scale: Math.min(1, root.width / Math.max(1, width))

        Behavior on width {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 200
                }
                NumberAnimation {
                    property: "scale"
                    to: 0.5
                    duration: 200
                }
            }
        }

        delegate: Item {
            id: cell

            required property int index

            // symbol: 0..1 amount of the big random symbol; dot: 0..1 of the final dot.
            property real symbol: 0
            property real dot: 0
            property int tick: 0

            // Only the newest character plays the full entrance; typing the next
            // one fast-forwards this one to its final dot.
            readonly property bool newest: index === root.count - 1

            width: root.cellWidth
            height: strip.height

            Component.onCompleted: life.start()

            onNewestChanged: {
                if (!newest) {
                    life.stop();
                    finish.start();
                }
            }

            ParallelAnimation {
                id: finish

                NumberAnimation {
                    target: cell
                    property: "symbol"
                    to: 0
                    duration: 140
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    target: cell
                    property: "dot"
                    to: 1
                    duration: 220
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.2
                }
            }

            SequentialAnimation {
                id: life

                ParallelAnimation {
                    NumberAnimation {
                        target: cell
                        property: "symbol"
                        from: 0
                        to: 1
                        duration: 700
                        easing.type: Easing.OutBack
                        easing.overshoot: 2.2
                    }
                }
                PauseAnimation {
                    duration: 700
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: cell
                        property: "symbol"
                        to: 0
                        duration: 420
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: cell
                        property: "dot"
                        to: 1
                        duration: 750
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
            }

            // Cycle glyphs and colours while the symbol is on show: a few changes only.
            Timer {
                interval: 420
                repeat: true
                running: cell.symbol > 0 && cell.dot < 0.05
                onTriggered: cell.tick++
            }

            Text {
                anchors.centerIn: parent

                text: root.symbolAt(cell.index + cell.tick * 7, root.salt + cell.tick * 3)
                color: root.tintAt(cell.index + cell.tick * 5, root.salt + cell.tick)
                opacity: Math.min(1, cell.symbol * 3)
                scale: cell.symbol
                font.family: Theme.symbolFont
                font.pixelSize: root.pixelSize * 1.2
            }

            Rectangle {
                anchors.centerIn: parent

                width: root.dotSize
                height: width
                radius: width / 2
                color: root.color
                scale: cell.dot
            }
        }
    }
}
