import QtQuick

Item {
    id: root

    property real spacing: 0

    readonly property var items: children.filter(c => c.fillWidth !== undefined)

    onWidthChanged: Qt.callLater(root.relayout)
    onChildrenChanged: Qt.callLater(root.relayout)
    Component.onCompleted: Qt.callLater(root.relayout)

    function relayout(): void {
        const list = items;
        if (list.length === 0)
            return;

        let maxHeight = 0;
        let fixed = 0;
        let fillCount = 0;
        for (const item of list) {
            maxHeight = Math.max(maxHeight, item.implicitHeight);
            if (item.fillWidth)
                fillCount++;
            else
                fixed += item.implicitWidth;
        }

        if (maxHeight !== root.implicitHeight)
            root.implicitHeight = maxHeight;

        const gap = root.spacing * (list.length - 1);
        const fillWidth = fillCount > 0 ? Math.max(0, (root.width - fixed - gap) / fillCount) : 0;

        let x = 0;
        for (const item of list) {
            item.x = x;
            item.width = item.fillWidth ? fillWidth : item.implicitWidth;
            item.height = maxHeight;
            x += item.width + root.spacing;
        }
    }
}
