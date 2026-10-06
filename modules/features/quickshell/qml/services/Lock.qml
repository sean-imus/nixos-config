pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.components
import qs.config

// Session lock: ext-session-lock via WlSessionLock, auth via PAM service
// "quickshell-lock" (NixOS: security.pam.services."quickshell-lock").
// Fallback if the shell dies while locked: run `swaylock` from a TTY.
//
// QS_LOCK_TEST=1 makes the lock release itself after 30 s, so a broken lock
// screen cannot trap the session while developing. Unset in normal use.
Singleton {
    id: root

    readonly property bool testMode: Quickshell.env("QS_LOCK_TEST") === "1"
    // Dev only: show HH:ss on a per-second clock to see the digit roll quickly.
    readonly property bool fastClock: Quickshell.env("QS_LOCK_CLOCK") === "seconds"
    readonly property string timeFormat: fastClock ? "HH:ss" : "HH:mm"
    // Fast mode also puts the seconds in the day slot so the date roll is visible.
    readonly property string dateFormat: fastClock ? "dddd, ss MMMM yyyy" : "dddd, dd MMMM yyyy"

    // Shared state so every output's surface stays in sync.
    property string entry
    // Password submitted, waiting for PAM's verdict (it delays after a failure).
    property bool checking
    // Last attempt failed; cleared on the next keypress.
    property bool failed
    // Bumped on every failure to trigger the shake animation.
    property int failures
    // Seed for the per-character symbols; changes per lock and per failure.
    property int dotSalt
    // 0..1 progress of the show/hide choreography; each element derives its own
    // staggered slice from it via stage().
    property real reveal: 0
    // Correct password accepted; playing the exit animation before releasing.
    property bool leaving
    // 0..1 progress of the calm exit (fade and drift up, no spin).
    property real outro: 0
    // Lock requested, waiting for the per-output screenshots to finish.
    property bool engaging
    property int pendingShots

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")

    function shotPath(name) {
        return runtimeDir + "/qs-lock-" + name + ".png";
    }

    function inOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }

    // Exit slice for an element with the given start delay.
    function outStage(delay) {
        return inOutCubic(Math.min(1, Math.max(0, (outro - delay) / (1 - delay))));
    }

    function fade(delay) {
        return 1 - outStage(delay);
    }

    function drift(delay) {
        return -48 * outStage(delay);
    }

    function stage(delay, span) {
        return Math.min(1, Math.max(0, (reveal - delay) / span));
    }

    function outCubic(t) {
        return 1 - Math.pow(1 - t, 3);
    }

    function outBack(t) {
        const c = 1.9;
        return 1 + (c + 1) * Math.pow(t - 1, 3) + c * Math.pow(t - 1, 2);
    }

    // Grab each output before the lock surface covers it (screencopy would
    // only see the lock afterwards); the background is a blurred copy of it.
    function lock() {
        if (sessionLock.locked || engaging)
            return;
        engaging = true;
        pendingShots = shots.instances.length;
        if (pendingShots === 0) {
            engage();
            return;
        }
        // Never delay the lock for long if grim is slow or missing.
        lockFallback.restart();
        for (let i = 0; i < shots.instances.length; i++)
            shots.instances[i].capture();
    }

    function shotDone() {
        if (engaging && --pendingShots <= 0)
            engage();
    }

    function engage() {
        if (!engaging)
            return;
        engaging = false;
        lockFallback.stop();
        entry = "";
        dotSalt = Math.floor(Math.random() * 1000);
        checking = false;
        failed = false;
        leaving = false;
        outro = 0;
        reveal = 0;
        enter.restart();
        sessionLock.locked = true;
        // Not driven by lockStateChanged: that only fires once the compositor
        // confirms the lock.
        pam.start();
        if (testMode)
            testUnlock.restart();
        // Surfaces load the screenshots synchronously on creation; drop the
        // files from the runtime dir right after.
        cleanup.restart();
    }

    function submit() {
        if (!pam.responseRequired || entry.length === 0)
            return;
        // Keep the dots on screen until PAM answers: clearing them here made them
        // shrink and drift while the pill was already animating away.
        checking = true;
        pam.respond(entry);
    }

    function cancelAuth() {
        pam.abort();
        entry = "";
        checking = false;
        failed = false;
        pam.start();
    }

    function type(event) {
        if (checking || leaving)
            return;
        failed = false;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            submit();
        else if (event.key === Qt.Key_Escape)
            cancelAuth();
        else if (event.key === Qt.Key_Backspace)
            entry = entry.slice(0, -1);
        else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && !(event.modifiers & Qt.ControlModifier))
            entry += event.text;
    }

    PamContext {
        id: pam

        config: "quickshell-lock"
        user: Quickshell.env("USER")

        onCompleted: result => {
            root.checking = false;
            if (result === PamResult.Success) {
                root.leaving = true;
                exit.restart();
            } else {
                root.entry = "";
                root.failed = true;
                root.failures++;
                root.dotSalt++;
                pam.start();
            }
        }

        onError: {
            root.entry = "";
            root.checking = false;
            pam.start();
        }
    }

    WlSessionLock {
        id: sessionLock

        locked: false

        // The NOTIFY signal of `locked` is lockStateChanged (no lockedChanged).
        onLockStateChanged: {
            if (!sessionLock.locked) {
                pam.abort();
                testUnlock.stop();
                enter.stop();
                root.reveal = 0;
                root.outro = 0;
                cleanup.restart();
            }
        }

        WlSessionLockSurface {
            id: surface

            color: Theme.bg0

            SystemClock {
                id: clock

                precision: root.fastClock ? SystemClock.Seconds : SystemClock.Minutes
            }

            // Blurred copy of this output as it was when the lock was requested.
            Image {
                id: shot

                anchors.fill: parent
                visible: false
                source: "file://" + root.shotPath(surface.screen.name)
                asynchronous: false
                cache: false
                fillMode: Image.PreserveAspectCrop
                smooth: true
                // Decoding at a tiny size is most of the blur; the effect below
                // removes the blockiness, so no readable detail survives.
                sourceSize.width: 128
            }

            MultiEffect {
                anchors.fill: parent
                source: shot
                visible: shot.status === Image.Ready
                autoPaddingEnabled: false
                blurEnabled: true
                blur: 1
                blurMax: 64
                brightness: -0.15
                saturation: -0.2
                opacity: root.stage(0, 0.8)
            }

            // Tint towards the palette so the text stays readable.
            Rectangle {
                anchors.fill: parent
                color: Theme.bg0
                opacity: shot.status === Image.Ready ? 0.45 * root.stage(0, 0.8) : 0
            }

            // Pulse ring expanding from the centre as the lock lands.
            Rectangle {
                readonly property real t: root.leaving ? 1 : root.outCubic(root.stage(0, 0.9))

                anchors.centerIn: parent

                width: Math.max(parent.width, parent.height) * 1.3
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 2
                border.color: Theme.green
                scale: t
                opacity: 0.45 * (1 - t)
            }

            // Clock colon breathing, one full cycle per second (2 x 500 ms); steady until
            // the lock has settled.
            QtObject {
                id: colonPulse

                property real level: 1

                SequentialAnimation on level {
                    running: root.reveal >= 1 && !root.leaving
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.3
                        duration: 500
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: 1
                        duration: 500
                        easing.type: Easing.InOutSine
                    }
                }
            }

            // Raw key capture instead of a TextField: no enabled/focus states to
            // get out of sync with PAM.
            Item {
                id: keys

                anchors.fill: parent
                focus: true

                Keys.onPressed: event => {
                    root.type(event);
                    event.accepted = true;
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 10

                // Time: every glyph flies in from its own edge, spinning into place.
                Row {
                    id: timeRow

                    // x, y offset and spin the glyph starts from.
                    readonly property var origins: [[0, -900, -270], [-1100, 0, 200], [0, 900, 360], [1100, 0, -200], [0, -900, 270]]

                    anchors.horizontalCenter: parent.horizontalCenter

                    readonly property string str: Qt.formatDateTime(clock.date, root.timeFormat)

                    // Persistent per-position delegates, so a changing digit can roll
                    // instead of being recreated.
                    Repeater {
                        model: 5

                        Item {
                            id: glyph

                            required property int index

                            readonly property var o: timeRow.origins[index]
                            readonly property real p: root.outBack(root.stage(index * 0.05, 0.6))
                            readonly property string char: timeRow.str.charAt(index)
                            readonly property bool colon: char === ":"

                            // Previous character and the 0..1 progress of its roll-out.
                            property string last: char
                            property string old
                            property real roll: 1

                            implicitWidth: cur.implicitWidth
                            implicitHeight: cur.implicitHeight

                            onCharChanged: {
                                old = last;
                                last = char;
                                if (old !== "")
                                    rollAnim.restart();
                            }

                            NumberAnimation {
                                id: rollAnim

                                target: glyph
                                property: "roll"
                                from: 0
                                to: 1
                                duration: 650
                                easing.type: Easing.OutCubic
                            }

                            // The colon breathes once settled.
                            opacity: Math.min(1, p * 2) * (colon ? colonPulse.level : 1) * root.fade(0.1)
                            rotation: o[2] * (1 - p)
                            transform: Translate {
                                x: glyph.o[0] * (1 - glyph.p)
                                y: glyph.o[1] * (1 - glyph.p) + root.drift(0.1)
                            }

                            // Outgoing digit: lifts away and fades.
                            Text {
                                y: -glyph.roll * font.pixelSize * 0.55
                                opacity: 1 - glyph.roll
                                scale: 1 - 0.15 * glyph.roll
                                text: glyph.old
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 64
                                font.bold: true
                            }

                            // Incoming digit: rises into place from below.
                            Text {
                                id: cur

                                y: (1 - glyph.roll) * font.pixelSize * 0.55
                                opacity: glyph.roll
                                scale: 0.85 + 0.15 * glyph.roll
                                text: glyph.char
                                color: glyph.colon ? Theme.green : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 64
                                font.bold: true
                            }
                        }
                    }
                }

                // Date: letters swarm in from all around the screen and assemble.
                // When the date text changes (midnight) the whole line lifts away
                // and the new one rises in, letter by letter.
                Item {
                    id: dateBox

                    readonly property string str: Qt.formatDateTime(clock.date, root.dateFormat).replace(/ /g, "\u00a0")

                    // Previous text and the 0..1 progress of the change.
                    property string last: str
                    property string old
                    property real roll: 1

                    anchors.horizontalCenter: parent.horizontalCenter
                    implicitWidth: dateRow.implicitWidth
                    implicitHeight: dateRow.implicitHeight

                    onStrChanged: {
                        old = last;
                        last = str;
                        if (old !== "")
                            dateRollAnim.restart();
                    }

                    NumberAnimation {
                        id: dateRollAnim

                        target: dateBox
                        property: "roll"
                        from: 0
                        to: 1
                        duration: 1000
                        easing.type: Easing.Linear
                    }

                    // Outgoing line.
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: dateBox.old.length

                            Text {
                                id: gone

                                required property int index

                                readonly property real r: root.outCubic(Math.min(1, Math.max(0, (dateBox.roll - index * 0.016) / 0.6)))

                                text: dateBox.old.charAt(index)
                                opacity: (1 - r) * root.fade(0.2)
                                transform: Translate {
                                    y: -gone.r * 18 + root.drift(0.2)
                                }
                                color: Theme.grey2
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                            }
                        }
                    }

                    // Current line. The model is the length, so letters persist
                    // across ticks and only their text changes.
                    Row {
                        id: dateRow

                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: dateBox.str.length

                            Text {
                                id: letter

                                required property int index

                                // Golden-angle spread so letters come from every direction.
                                readonly property real angle: index * 2.399
                                readonly property real dist: 500 + (index * 97 % 7) * 70
                                readonly property real p: root.outBack(root.stage(0.12 + index * (0.35 / Math.max(1, dateBox.str.length)), 0.5))
                                readonly property real r: root.outCubic(Math.min(1, Math.max(0, (dateBox.roll - index * 0.016) / 0.6)))

                                text: dateBox.str.charAt(index)
                                opacity: Math.min(1, p * 2) * r * root.fade(0.2)
                                rotation: (index % 2 === 0 ? -240 : 240) * (1 - p)
                                transform: Translate {
                                    x: Math.cos(letter.angle) * letter.dist * (1 - letter.p)
                                    y: Math.sin(letter.angle) * letter.dist * (1 - letter.p) + (1 - letter.r) * 18 + root.drift(0.2)
                                }
                                color: Theme.grey2
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                Item {
                    width: 1
                    height: 8
                }

                Rectangle {
                    id: box

                    anchors.horizontalCenter: parent.horizontalCenter

                    // Compact around the hint until typing starts, then opens up.
                    width: root.entry.length > 0 ? 380 : hint.implicitWidth + 72
                    height: 56
                    radius: height / 2
                    color: Theme.bg1
                    border.width: 1
                    border.color: root.failed ? Theme.red : (keys.activeFocus || root.leaving) ? Theme.green : Theme.bg3

                    readonly property real p: root.outBack(root.stage(0.28, 0.72))

                    Behavior on width {
                        NumberAnimation {
                            duration: 380
                            easing.type: Easing.OutCubic
                        }
                    }

                    opacity: Math.min(1, root.stage(0.28, 0.4)) * root.fade(0)
                    transform: [
                        Translate {
                            id: shift
                        },
                        Translate {
                            y: (1 - box.p) * 180 + root.drift(0)
                        },
                        Scale {
                            origin.x: box.width / 2
                            origin.y: box.height / 2
                            xScale: 0.8 + 0.2 * box.p
                            yScale: xScale
                        }
                    ]

                    SequentialAnimation {
                        id: shake

                        NumberAnimation {
                            target: shift
                            property: "x"
                            to: -10
                            duration: 50
                        }
                        NumberAnimation {
                            target: shift
                            property: "x"
                            to: 10
                            duration: 80
                        }
                        NumberAnimation {
                            target: shift
                            property: "x"
                            to: -6
                            duration: 70
                        }
                        NumberAnimation {
                            target: shift
                            property: "x"
                            to: 0
                            duration: 50
                        }
                    }

                    Connections {
                        target: root

                        function onFailuresChanged() {
                            shake.restart();
                        }
                    }

                    SecretDots {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18

                        count: root.entry.length
                        salt: root.dotSalt
                        // Dimmed while PAM is checking.
                        opacity: root.checking ? 0.45 : 1
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                        pixelSize: 20
                    }

                    // Hint while nothing is typed; fades out as the first dot lands.
                    Text {
                        id: hint

                        anchors.centerIn: parent

                        opacity: root.entry.length === 0 ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                        text: root.checking ? "Checking…" : "Enter your password"
                        color: Theme.grey0
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter

                    opacity: root.failed ? root.fade(0) : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    text: "Incorrect password"
                    color: Theme.red
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }
    }

    NumberAnimation {
        id: enter

        target: root
        property: "reveal"
        from: 0
        to: 1
        duration: 1400
    }

    SequentialAnimation {
        id: exit

        NumberAnimation {
            target: root
            property: "outro"
            from: 0
            to: 1
            duration: 800
        }
        ScriptAction {
            script: {
                root.leaving = false;
                sessionLock.locked = false;
            }
        }
    }

    Variants {
        id: shots

        model: Quickshell.screens

        QtObject {
            id: shotEntry

            required property ShellScreen modelData

            function capture() {
                grim.running = true;
            }

            property Process grim: Process {
                command: ["grim", "-o", shotEntry.modelData.name, root.shotPath(shotEntry.modelData.name)]
                onExited: root.shotDone()
            }
        }
    }

    Process {
        id: rm

        command: ["sh", "-c", "rm -f \"$XDG_RUNTIME_DIR\"/qs-lock-*.png"]
    }

    Timer {
        id: cleanup

        interval: 2000
        onTriggered: rm.running = true
    }

    Timer {
        id: lockFallback

        interval: 700
        onTriggered: root.engage()
    }

    Timer {
        id: testUnlock

        interval: 30000
        onTriggered: sessionLock.locked = false
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }
    }
}
