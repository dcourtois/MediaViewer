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
				const size = player.metaData.resolution;
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
				controls.setPosition(0);
				output.resize();
			}
		}
	}

	// mouse area to detect movement to display / hide the controls
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		propagateComposedEvents: true
		onPositionChanged: controls.show()
		onEntered: controls.show()
		onExited: controls.hide()
	}

	// detect size changes
	Connections {
		target: root
		onWidthChanged: { output.resize(); controls.setPosition(player.position); }
		onHeightChanged: { output.resize(); controls.setPosition(player.position); }
	}

	// movie controls
	MovieControls {
		id: controls
		player: player
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 10
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
