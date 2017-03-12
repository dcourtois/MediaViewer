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
	enabled: selection && selection.currentMedia && selection.currentMedia.type === Media.Movie
	visible: enabled
	focus: enabled && stateManager.state === "fullscreen"

	// the media player
	VideoOutput {
		id: output
		source: mediaPlayer
		autoOrientation: true

		// the player
		MediaPlayer {
			id: mediaPlayer
			source: enabled ? selection.currentMedia.path : ""
			autoPlay: false
			muted: true

			// update the output size
			function updateSizing(force) {
				if ((force === true && metaData.resolution !== undefined) || status === MediaPlayer.Loaded) {
					var size = metaData.resolution;
					if (size.width >= root.width || size.height >= root.height) {
						output.anchors.centerIn = undefined;
						output.anchors.fill = root;
					} else {
						output.anchors.fill = undefined;
						output.width = size.width;
						output.height = size.height;
						output.anchors.centerIn = root;
					}
				}
			}

			// update the sizing when needed
			onStatusChanged: updateSizing()
			onSourceChanged: updateSizing()
		}
	}

	// detect current media changes
	Connections {
		target: selection
		onCurrentMediaChanged: {
			// always stop playback and show controls
			mediaPlayer.stop();
			controls.show();

			// the following only needs to be done when it's a movie
			if (enabled) {
				// update the preview
				preview.update(mediaPlayer.position / mediaPlayer.duration);

				// if we are in fullscreen, show controls again
				if (stateManager.state === "fullscreen") {
					controls.autoHide();
				}
			}
		}
	}

	// check the fullscreen / preview state to force controls on preview
	Connections {
		target: stateManager
		onStateChanged: {
			// update the mediaPlayer's sizing
			mediaPlayer.updateSizing(true);

			// update preview
			preview.update(mediaPlayer.position / mediaPlayer.duration);

			// display or hide the controls
			if (stateManager.state === "preview") {
				controls.show();
			} else if (stateManager.state === "fullscreen") {
				controls.autoHide();
			}
		}
	}

	// preview image
	Image {
		id: preview
		anchors.fill: parent
		visible: mediaPlayer.playbackState === MediaPlayer.StoppedState
		fillMode: sourceSize.width >= width || sourceSize.height >= height ? Image.PreserveAspectFit : Image.Pad
		function update(time) {
			if (mediaPlayer.playbackState === MediaPlayer.StoppedState) {
				source = selection.currentMedia ? "image://Thumbnail/" + time + "/" + selection.currentMedia.path : "";
			}
		}
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

	// Mouse area on the whole video
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton
		hoverEnabled: true

		// detect mouse moves to show the cursor
		onPositionChanged: {
			if (stateManager.state == "fullscreen") {
				controls.autoHide();
			}
		}

		// double click toggles fullscreen / preview
		onDoubleClicked: {
			if (stateManager.state == "fullscreen") {
				stateManager.state = "preview";
			} else {
				stateManager.state = "fullscreen";
			}
		}

		// on simple clicks, pause / resume video
		onClicked: {
			if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
				mediaPlayer.pause();
			} else {
				mediaPlayer.play();
			}
		}
	}

	// movie controls
	Rectangle {
		id: controls
		property bool _containsCursor: false

		// show the controls and disable auto-hide
		function show() {
			controls.visible = true;
			cursor.hidden = false;
			timer.stop();
		}

		// show the controls and restart the auto-hide
		function autoHide() {
			if (_containsCursor === false) {
				controls.visible = true;
				cursor.hidden = false;
				timer.restart();
			}
		}

		// size and color
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
		}
		height: 80
		color: Qt.rgba(0.3, 0.3, 0.3, 0.3)

		// when the cursor is in the mouse area, let the controls visible
		MouseArea {
			anchors.fill: parent
			acceptedButtons: Qt.LeftButton
			hoverEnabled: true

			// disable the play / pause on the controls (override the whole video mouse area)
			onClicked: mouse.accepted = true

			// when entering the area, show the controls
			onEntered: { parent._containsCursor = true; parent.show(); }

			// when leaving, autohide
			onExited: { parent._containsCursor = false; parent.autoHide(); }
		}

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
					onClicked: {
						mediaPlayer.stop();
						preview.update(0);
					}
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
				acceptedButtons: Qt.LeftButton
				onClicked: {
					mediaPlayer.seek((mouseX / width) * mediaPlayer.duration);
					preview.update(mouseX / width);
				}
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

		// the timer used to hide / show the controls
		Timer {
			id: timer
			interval: 2000
			onTriggered: {
				controls.visible = false;
				cursor.hidden = true;
			}
		}
	}
}
