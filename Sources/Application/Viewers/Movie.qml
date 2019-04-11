import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.8


//
// Movie viewer
//
Item {
	id: root

	// expose the source (like ImageViewer and AnimatedImageViewer)
	property alias source: player.source

	// acquire focus for movie specific shortcuts
	focus: true

	// the media player
	VideoOutput {
		id: output
		source: player
		autoOrientation: true

		// resize
		function resize() {
			if (player.metaData && player.metaData.resolution) {
				var size = player.metaData.resolution;
				if (size.width >= root.width || size.height >= root.height) {
					anchors.centerIn = undefined;
					anchors.fill = root;
				} else {
					anchors.fill = undefined;
					width = size.width;
					height = size.height;
					anchors.centerIn = root;
				}
			}
		}
	}

	// the player
	MediaPlayer {
		id: player
		autoPlay: false
		muted: true

		// update the sizing when ready to play
		onStatusChanged: {
			if (status === MediaPlayer.Loaded) {
				root.setPosition(100);
				output.resize();
			}
		}
	}

	// detect size changes
	Connections {
		target: root
		onWidthChanged: { output.resize(); root.setPosition(player.position); }
		onHeightChanged: { output.resize(); root.setPosition(player.position); }
	}

	// set the image at the given position
	function setPosition(position) {
		player.seek(position);
		if (player.playbackState !== player.PlayingState) {
			player.play();
			player.pause();
		}
	}

	// movie controls
	Rectangle {
		id: controls

		// size and color
		height: 80
		color: Qt.rgba(0.3, 0.3, 0.3, 0.3)
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
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
					onClicked: { player.stop(); root.setPosition(100); }
				}
			}
			Image {
				sourceSize { width: 40; height: 40 }
				source: player.playbackState === MediaPlayer.PlayingState ? "qrc:/icons/pause" : "qrc:/icons/play"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
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
				width: parent.width * (player.position / player.duration)
			}

			// detect user click to seek the movie
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton
				onClicked: player.seek((mouseX / width) * player.duration);
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
			text: formatTime(player.position) + " / " + formatTime(player.duration)
		}
	}

	// Movie specific keyboard handling
	Keys.onPressed: {
		switch (event.key) {
			// play / pause
			case Qt.Key_Space:
				event.accepted = true;
				player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play();
				break;

			// let the rest be handled by the parent
			default:
				event.accepted = false;
		}
	}
}
