import QtQuick 2.5
import QtQuick.Controls 1.4
import MediaViewerLib 0.1


//
// Animated image view
//
AnimatedImage {
	id: image
	anchors.fill: parent

	// externally set
	property var selection
	property var stateManager

	// only enable for images
	enabled: selection && selection.currentMediaType === Media.AnimatedImage
	visible: enabled
	focus: enabled && stateManager.state === "fullscreen"

	// when loosing focus, switch back to preview state
	onActiveFocusChanged: if (activeFocus === false && selection.currentMediaType === Media.AnimatedImage) { stateManager.state = "preview"; }

	// auto-play on load
	onStatusChanged: playing = (status == AnimatedImage.Ready)

	// bind the source
	source: (enabled && selection) ? selection.currentMediaPath : "qrc:///images/empty"

	// only fit when the image is greater than the view size
	fillMode: sourceSize.width > width || sourceSize.height > height ? Image.PreserveAspectFit : Image.Pad

	// configure the image for best quality
	asynchronous: true
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true

	// Mouse area to catch double clicks
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		onDoubleClicked: {
			if (stateManager.state == "fullscreen") {
				stateManager.state = "preview";
			} else {
				stateManager.state = "fullscreen";
			}
		}
	}

	// keyboard navigation
	Keys.onPressed: {
		if (activeFocus == false) {
			return;
		}
		switch (event.key) {
			case Qt.Key_Left:
			case Qt.Key_Up:
				event.accepted = true;
				selection.selectPrevious();
				break;
			case Qt.Key_Right:
			case Qt.Key_Down:
				event.accepted = true;
				selection.selectNext();
				break;
			case Qt.Key_Return:
			case Qt.Key_Enter:
			case Qt.Key_Escape:
				stateManager.state = "preview";
				break;
		}
	}
}
