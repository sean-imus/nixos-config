pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.services

QtObject {
    id: notif

    property bool popup
    property bool closed
    property var locks: new Set()

    property date time: new Date()
    property string timeStr: qsTr("now")

    readonly property Timer timeStrTimer: Timer {
        running: !notif.closed
        repeat: true
        interval: 5000
        onTriggered: notif.updateTimeStr()
    }

    property Notification notification
    property string notificationId
    property string summary
    property string body
    property string appIcon
    property string appName
    property string image
    property var hints // Hints are not persisted across restarts
    property real expireTimeout: GlobalConfig.notifs.defaultExpireTimeout
    property int urgency: NotificationUrgency.Normal
    property bool resident
    property bool hasActionIcons
    property list<var> actions

    readonly property bool hasFullscreen: Niri.fullscreen

    readonly property Timer timer: Timer {
        running: true
        interval: notif.expireTimeout > 0 ? notif.expireTimeout : notif.hasFullscreen ? GlobalConfig.notifs.fullscreenExpireTimeout : GlobalConfig.notifs.defaultExpireTimeout
        onTriggered: {
            // A timeout of 0 means "never expire"
            if (notif.expireTimeout === 0)
                return;

            // Keep critical notifications (without an explicit timeout) visible
            if (notif.urgency === NotificationUrgency.Critical && notif.expireTimeout < 0)
                return;

            // Always expire if the active workspace has a fullscreen window
            if (GlobalConfig.notifs.expire || notif.hasFullscreen)
                notif.popup = false;
        }
    }

    // Quickshell updates replaced notifications (replaces_id) in place without
    // re-emitting the server's notification signal, so refresh the popup here
    // instead of waiting for a new NotifData.
    function refresh(): void {
        if (closed)
            return;

        time = new Date();
        updateTimeStr();
        popup = Notifs.shouldShowPopup();
        timer.restart();
        Notifs.requestSave();
    }

    readonly property Connections conn: Connections {
        function onClosed(): void {
            notif.close();
        }

        function onSummaryChanged(): void {
            notif.summary = notif.notification.summary;
            notif.refresh();
        }

        function onBodyChanged(): void {
            notif.body = notif.notification.body;
            notif.refresh();
        }

        function onAppIconChanged(): void {
            notif.appIcon = notif.notification.appIcon;
        }

        function onAppNameChanged(): void {
            notif.appName = notif.notification.appName;
        }

        function onImageChanged(): void {
            notif.image = notif.notification.image;
        }

        function onExpireTimeoutChanged(): void {
            notif.expireTimeout = notif.notification.expireTimeout;
        }

        function onUrgencyChanged(): void {
            notif.urgency = notif.notification.urgency;
        }

        function onResidentChanged(): void {
            notif.resident = notif.notification.resident;
        }

        function onHasActionIconsChanged(): void {
            notif.hasActionIcons = notif.notification.hasActionIcons;
        }

        function onActionsChanged(): void {
            // qmllint disable unresolved-type
            notif.actions = notif.notification.actions.map(a => ({
                        // qmllint enable unresolved-type
                        identifier: a.identifier,
                        text: a.text,
                        invoke: () => a.invoke()
                    }));
        }

        function onHintsChanged(): void {
            notif.hints = notif.notification.hints;
        }

        target: notif.notification
    }

    function updateTimeStr(): void {
        const diff = Date.now() - time.getTime();
        const m = Math.floor(diff / 60000);

        if (m < 1) {
            timeStr = qsTr("now");
            timeStrTimer.interval = 5000;
        } else {
            const h = Math.floor(m / 60);
            const d = Math.floor(h / 24);

            if (d > 0) {
                timeStr = `${d}d`;
                timeStrTimer.interval = 3600000;
            } else if (h > 0) {
                timeStr = `${h}h`;
                timeStrTimer.interval = 300000;
            } else {
                timeStr = `${m}m`;
                timeStrTimer.interval = m < 10 ? 30000 : 60000;
            }
        }
    }

    function lock(item: Item): void {
        locks.add(item);
    }

    function unlock(item: Item): void {
        locks.delete(item);
        if (closed)
            close();
    }

    function close(): void {
        closed = true;
        if (locks.size === 0 && Notifs.list.includes(this)) {
            Notifs.list = Notifs.list.filter(n => n !== this);
            notification?.dismiss();
            destroy();
        }
    }

    Component.onCompleted: {
        if (!notification)
            return;

        notificationId = notification.id;
        summary = notification.summary;
        body = notification.body;
        appIcon = notification.appIcon;
        appName = notification.appName;
        image = notification.image;
        expireTimeout = notification.expireTimeout;
        hints = notification.hints;
        urgency = notification.urgency;
        resident = notification.resident;
        hasActionIcons = notification.hasActionIcons;
        // qmllint disable unresolved-type
        actions = notification.actions.map(a => ({
                    // qmllint enable unresolved-type
                    identifier: a.identifier,
                    text: a.text,
                    invoke: () => a.invoke()
                }));
    }
}
