pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    property var list: []
    readonly property var popups: root.list.filter(entry => entry.visible)
    property bool dnd

    function toggleDnd(): void {
        root.dnd = !root.dnd;
    }

    function clear(): void {
        for (const entry of root.list.slice())
            root.dismiss(entry);
    }

    function dismiss(entry): void {
        if (entry.notification)
            entry.notification.dismiss();

        root.remove(entry);
    }

    function invokeAction(entry, identifier): void {
        if (entry.notification)
            entry.notification.invokeAction(identifier);

        root.dismiss(entry);
    }

    function remove(entry): void {
        if (entry.timer)
            entry.timer.destroy();

        const index = root.list.indexOf(entry);
        if (index === -1)
            return;

        const copy = root.list.slice();
        copy.splice(index, 1);
        root.list = copy;
    }

    function push(notif, visible): void {
        const entry = {
            notification: notif,
            id: notif.id,
            appName: notif.appName,
            summary: notif.summary,
            body: notif.body,
            urgency: notif.urgency,
            actions: notif.actions.map(action => ({
                    identifier: action.identifier,
                    label: action.label
                })),
            visible: visible
        };

        notif.closed.connect(() => root.remove(entry));

        // -1 (never) or unset: critical notifications stay until dismissed,
        // everything else gets the standard 6s timeout.
        const timeout = notif.expireTimeout > 0 ? notif.expireTimeout
            : (notif.urgency === NotificationUrgency.Critical ? 0 : 6000);

        if (visible && timeout > 0) {
            const timer = timerComp.createObject(root, {
                interval: timeout
            });
            entry.timer = timer;
            timer.triggered.connect(() => {
                notif.expire();
                root.remove(entry);
            });
            timer.restart();
        }

        root.list = [entry, ...root.list];
    }

    function expireLater(notif, interval): void {
        const timer = timerComp.createObject(root, {
            interval: interval
        });
        timer.triggered.connect(() => {
            notif.expire();
            Qt.callLater(timer, "destroy");
        });
        timer.restart();
    }

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        actionsSupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        imageSupported: false
        inlineReplySupported: false
        persistenceSupported: false

        onNotification: notif => {
            notif.tracked = true;

            // Under DND: accepted, but never displayed and auto-expired quickly.
            if (root.dnd)
                root.expireLater(notif, 500);
            else
                root.push(notif, true);
        }
    }

    Component {
        id: timerComp

        Timer {
            repeat: false
        }
    }

    IpcHandler {
        target: "notifs"

        function toggleDnd(): void {
            root.toggleDnd();
        }

        function clear(): void {
            root.clear();
        }
    }
}
