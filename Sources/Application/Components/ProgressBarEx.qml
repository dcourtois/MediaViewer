import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import MediaViewer 0.1


//
// Custom progress bar which will not capture mouse events ... This can serve as a slider too.
//
Item {

	// if true, the progress bar behaves like a slider
	property bool interactive: true

	// look & feel
	property int backgroundSize: 6
	property color backgroundColor: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.4)
	property int foregroundSize: 12
	property color foregroundColor: Material.accent
	property real position: 0
	property var direction: Qt.Horizontal

	// clamped position
	property real clampedPosition: Math.min(1, Math.max(position))

	// the background
	Rectangle {
		anchors.left: direction === Qt.Horizontal ? parent.left : undefined
		anchors.right: direction === Qt.Horizontal ? parent.right : undefined
		anchors.verticalCenter: direction === Qt.Horizontal ? parent.verticalCenter : undefined 
		height: direction === Qt.Horizontal ? backgroundSize : undefined

		anchors.top: direction === Qt.Vertical ? parent.top : undefined
		anchors.bottom: direction === Qt.Vertical ? parent.bottom : undefined
		anchors.horizontalCenter: direction === Qt.Vertical ? parent.horizontalCenter : undefined 
		width: direction === Qt.Vertical ? backgroundSize : undefined

		color: parent.backgroundColor
	}

	// the actual progress
	Rectangle {
		anchors.left: direction === Qt.Horizontal ? parent.left : undefined
		anchors.verticalCenter: direction === Qt.Horizontal ? parent.verticalCenter : undefined
		width: direction === Qt.Horizontal ? parent.width * parent.clampedPosition : foregroundSize

		anchors.bottom: direction === Qt.Vertical ? parent.bottom : undefined
		anchors.horizontalCenter: direction === Qt.Vertical ? parent.horizontalCenter : undefined 
		height: direction === Qt.Vertical ? parent.height * parent.clampedPosition : foregroundSize

		color: parent.foregroundColor
	}

	// mouse area
	MouseArea {
		anchors.fill: parent
		enabled: parent.interactive
		acceptedButtons: Qt.LeftButton
		function setPosition(mouse) {
			if (parent.direction === Qt.Horizontal) {
				parent.position = Math.min(1, Math.max(0, mouse.x / parent.width));
			} else {
				parent.position = Math.min(1, Math.max(0, mouse.y / parent.height));
			}
		}
		onPressed: setPosition(mouse)
		onPositionChanged: setPosition(mouse)
	}
}
