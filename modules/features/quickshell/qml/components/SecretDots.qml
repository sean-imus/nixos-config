import QtQuick
import qs.config

// Hidden-input display: one random symbol per typed character instead of a
// dot. A new symbol scrambles through random glyphs while it pops and spins
// into place. Symbols are a pure function of (index, salt), so several
// instances given the same salt (one per monitor) always agree.
Item {
    id: root

    property int count
    property int salt
    property color color: Theme.fg
    property int pixelSize: 20

    readonly property string glyphs: "◆◇▲▼■□●○★✦✧✿❖✱✺"

    function symbolAt(index, seed) {
        const r = Math.abs(Math.sin((index + 1) * 12.9898 + seed * 78.233) * 43758.5453) % 1;
        return glyphs.charAt(Math.floor(r * glyphs.length));
    }

    implicitHeight: pixelSize * 1.4

    Row {
        id: row

        anchors.centerIn: parent

        // Shrink instead of overflowing when the password is long.
        scale: Math.min(1, root.width / Math.max(1, implicitWidth))

        Repeater {
            model: root.count

            Item {
                id: cell

                required property int index

                // 0..1 pop/scramble progress; starts when the symbol is typed.
                property real t: 0
                property int tick: 0
                readonly property string settled: root.symbolAt(index, root.salt)

                width: root.pixelSize * 1.2
                height: root.pixelSize * 1.4

                Component.onCompleted: pop.start()

                NumberAnimation {
                    id: pop

                    target: cell
                    property: "t"
                    from: 0
                    to: 1
                    duration: 320
                    easing.type: Easing.OutCubic
                }

                // Flicker through random glyphs until the pop has landed.
                Timer {
                    interval: 40
                    repeat: true
                    running: cell.t < 1
                    onTriggered: cell.tick++
                }

                Text {
                    anchors.centerIn: parent

                    text: cell.t < 0.7 ? root.symbolAt(cell.index + cell.tick * 7, cell.tick * 3 + 1) : cell.settled
                    color: root.color
                    opacity: Math.min(1, cell.t * 3)
                    scale: 1 + 0.9 * (1 - cell.t)
                    rotation: -120 * (1 - cell.t)
                    font.family: Theme.fontFamily
                    font.pixelSize: root.pixelSize
                }
            }
        }
    }
}
