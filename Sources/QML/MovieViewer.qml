import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import MediaViewer 0.1


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
	visible: enabled
	focus: enabled && stateManager.state === "fullscreen"

	// playing state
	property bool isPlaying: false

	// the media player
	MediaPlayer {
		id: mediaPlayer
		source: (enabled && selection) ? selection.currentMediaPath : ""
		autoPlay: false
		muted: true
		onError: {
			if (MediaPlayer.NoError !== error) {
				console.log("Error playing : " + source + " - " + errorString + "(error code: " + error + ")");
			}
		}

		// update playing state
		onPaused: root.isPlaying = false
		onPlaying: root.isPlaying = true
		onStopped: root.isPlaying = false
	}

	// keyboard navigation
	Keys.onPressed: {
		if (activeFocus === false) {
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

	// playback controls
	Rectangle {
		anchors {
			bottom: parent.bottom
			bottomMargin: 50
			horizontalCenter: parent.horizontalCenter
		}
		width: childrenRect.width
		height: childrenRect.height
		radius: 10
		color: Qt.rgba(0.3, 0.3, 0.3, 0.3)
		RowLayout {
			Image {
				sourceSize.width: 40
				sourceSize.height: 40
				source: "qrc:/icons/stop"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: mediaPlayer.stop()
				}
			}
			Image {
				sourceSize.width: 40
				sourceSize.height: 40
				source: root.isPlaying ? "qrc:/icons/pause" : "qrc:/icons/play"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: root.isPlaying ? mediaPlayer.pause() : mediaPlayer.play()
				}
			}
		}
	}
}
