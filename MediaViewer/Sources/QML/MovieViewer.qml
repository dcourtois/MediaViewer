import QtQuick 2.5
import QtQuick.Controls 1.4
import QtMultimedia 5.6
import MediaViewerLib 0.1


//
// Movie viewer
//
VideoOutput {
	id: root
	source: mediaPlayer

	// externally set
	property var selection
	property var stateManager

	// only enable for movies
	enabled: selection && selection.currentMediaType == Media.Movie

	// only visible when enabled
	visible: enabled

	// when loosing focus, switch back to preview state
	onActiveFocusChanged: if (activeFocus == false) { stateManager.state = "preview"; }

	// the media player
	MediaPlayer {
		id: mediaPlayer
		source: (enabled && selection) ? "file:///" + selection.currentMediaPath : ""
		autoPlay: true
		onError: {
			if (MediaPlayer.NoError != error) {
				console.log("[qmlvideo] VideoItem.onError error " + error + " errorString " + errorString)
			}
		}
	}

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
