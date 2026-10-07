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

Singleton {
    id: root

    readonly property bool testMode: Quickshell.env("QS_LOCK_TEST") === "1"

    readonly property bool fastClock: Quickshell.env("QS_LOCK_CLOCK") === "seconds"
    readonly property string timeFormat: fastClock ? "HH:ss" : "HH:mm"

    readonly property string dateFormat: fastClock ? "dddd, ss MMMM yyyy" : "dddd, dd MMMM yyyy"

    property string entry

    property bool checking

    property bool failed

    property int failures

    property int dotSalt

    property real reveal: 0

    property bool leaving

    property real outro: 0

    property bool engaging
    property int pendingShots

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")

    function shotPath(name) {
        return runtimeDir + "/qs-lock-" + name + ".png";
    }

    function inOutCubic(t) {
        return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2;
    }

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

    function lock() {
        if (sessionLock.locked || engaging)
            return;
        engaging = true;
        pendingShots = shots.instances.length;
        if (pendingShots === 0) {
            engage();
            return;
        }

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

        pam.start();
        if (testMode)
            testUnlock.restart();

        cleanup.restart();
    }

    function submit() {
        if (!pam.responseRequired || entry.length === 0)
            return;

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

            Image {
                id: shot

                anchors.fill: parent
                visible: false
                source: surface.screen ? "file://" + root.shotPath(surface.screen.name) : ""
                asynchronous: false
                cache: false
                fillMode: Image.PreserveAspectCrop
                smooth: true

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

            Rectangle {
                anchors.fill: parent
                color: Theme.bg0
                opacity: shot.status === Image.Ready ? 0.45 * root.stage(0, 0.8) : 0
            }

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

                Row {
                    id: timeRow

                    readonly property var origins: [[0, -900, -270], [-1100, 0, 200], [0, 900, 360], [1100, 0, -200], [0, -900, 270]]

                    anchors.horizontalCenter: parent.horizontalCenter

                    readonly property string str: Qt.formatDateTime(clock.date, root.timeFormat)

                    Repeater {
                        model: 5

                        Item {
                            id: glyph

                            required property int index

                            readonly property var o: timeRow.origins[index]
                            readonly property real p: root.outBack(root.stage(index * 0.05, 0.6))
                            readonly property string char: timeRow.str.charAt(index)
                            readonly property bool colon: char === ":"

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

                            opacity: Math.min(1, p * 2) * (colon ? colonPulse.level : 1) * root.fade(0.1)
                            rotation: o[2] * (1 - p)
                            transform: Translate {
                                x: glyph.o[0] * (1 - glyph.p)
                                y: glyph.o[1] * (1 - glyph.p) + root.drift(0.1)
                            }

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

                Item {
                    id: dateBox

                    readonly property string str: Qt.formatDateTime(clock.date, root.dateFormat).replace(/ /g, "\u00a0")

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

                    Row {
                        id: dateRow

                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: dateBox.str.length

                            Text {
                                id: letter

                                required property int index

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

                        opacity: root.checking ? 0.45 : 1
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                        pixelSize: 20
                    }

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
                command: ["grim", "-o", shotEntry.modelData?.name, root.shotPath(shotEntry.modelData?.name)]
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
