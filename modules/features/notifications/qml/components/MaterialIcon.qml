import QtQuick
import qs.config

StyledText {
    property real fill: 1
    property int grade
    property font fontStyle: Tokens.font.icon.small

    font: fontStyle
}
