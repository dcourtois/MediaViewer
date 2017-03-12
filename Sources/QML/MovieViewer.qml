import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import MediaViewer 0.1


//
// Movie viewer
//
Item {
	id: root

	// externally set
	property var selection
	property var stateManager

	// only enable for movies
	enabled: selection && selection.currentMediaType == Media.Movie
	visible: enabled
	focus: enabled && stateManager.state === "fullscreen"

	// the media player
	VideoOutput {
		id: output
		source: mediaPlayer

		// the player
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

			// update the video output sizing depending on the video resolution. This can be done
			// only when the status is "loaded".
			onStatusChanged: {
				if (status === MediaPlayer.Loaded) {
					var size = metaData.resolution;
					if (size.width >= parent.width || size.height >= parent.height) {
						output.anchors.centerIn = undefined;
						output.anchors.fill = root;
					} else {
						output.anchors.fill = undefined;
						output.anchors.centerIn = root;
					}
				}
			}
		}
	}

	// thumbnail
	Image {
		anchors.fill: parent
		visible: mediaPlayer.playbackState === MediaPlayer.StoppedState
		source: selection.currentMedia ? "image://Thumbnail/0/" + selection.currentMedia.path : ""
		fillMode: sourceSize.width >= width || sourceSize.height >= height ? Image.PreserveAspectFit : Image.Pad
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

			case Qt.Key_Space:
				mediaPlayer.playbackState === MediaPlayer.PlayingState ? mediaPlayer.pause() : mediaPlayer.play();
				break;
		}
	}

	// Mouse area to catch double clicks
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		hoverEnabled: true

		// detect mouse moves to show the cursor
		onPositionChanged: {
			if (stateManager.state == "fullscreen") {
				cursor.hidden = false;
			}
		}

		onDoubleClicked: {
			if (stateManager.state == "fullscreen") {
				stateManager.state = "preview";
			} else {
				stateManager.state = "fullscreen";
			}
		}
	}

	// movie controls
	Rectangle {
		id: controls
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: 80
		color: Qt.rgba(0.3, 0.3, 0.3, 0.3)

		// playback controls
		RowLayout {
			anchors {
				top: parent.top
				horizontalCenter: parent.horizontalCenter
			}
			Image {
				sourceSize { width: 40; height: 40 }
				source: "qrc:/icons/stop"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: mediaPlayer.stop()
				}
			}
			Image {
				sourceSize { width: 40; height: 40 }
				source: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "qrc:/icons/pause" : "qrc:/icons/play"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: mediaPlayer.playbackState === MediaPlayer.PlayingState ? mediaPlayer.pause() : mediaPlayer.play()
				}
			}
		}

		// seek bar background
		Rectangle {
			id: seekBar
			anchors {
				left: parent.left
				right: parent.right
				bottom: parent.bottom
			}
			height: 15
			color: Qt.rgba(0, 0, 0, 1)

			// active seek bar
			Rectangle {
				anchors {
					left: parent.left
					top: parent.top
					bottom: parent.bottom
				}
				color: Qt.rgba(1, 1, 1, 1)
				width: parent.width * (mediaPlayer.position / mediaPlayer.duration)
			}

			// detect user click to seek the movie
			MouseArea {
				anchors.fill: parent
				onClicked: mediaPlayer.seek((mouseX / width) * mediaPlayer.duration)
			}
		}

		// time
		Text {
			anchors {
				bottom: seekBar.top
				bottomMargin: 10
				horizontalCenter: parent.horizontalCenter
			}

			// t is the time in milliseconds
			function formatTime(t) {
				var d = new Date(t),
					h = d.getUTCHours(),
					m = d.getUTCMinutes(),
					s = d.getSeconds();
				return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
			}

			color: Qt.rgba(1, 1, 1, 1)
			text: formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)
		}
	}
}
