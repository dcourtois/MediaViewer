import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.12


//
// Movie viewer
//
Item {
	id: root

	// expose the source
	property alias source: player.source

	// acquire focus for movie specific shortcuts
	focus: true

	// show the controls when needed
	Connections { target: rootView; onFullscreenChanged: controls.show() }
	Connections { target: selection; onCurrentChanged: controls.show() }

	// the media player
	VideoOutput {
		id: output
		source: player
		autoOrientation: true

		// init anchors
		anchors.fill: fullscreen === true ? root : undefined
		anchors.centerIn: fullscreen === false ? root : undefined

		// if this is true, the video fills the parent area
		property bool fullscreen: settings.get("Movie.Fullscreen")

		// update the anchor on fullscreen change
		onFullscreenChanged: {
			if (fullscreen === true) {
				anchors.fill = root;
				anchors.centerIn = undefined;
			} else {
				anchors.fill = undefined;
				anchors.centerIn = root;
				resize();
			}
			settings.set("Movie.Fullscreen", fullscreen);
		}

		// resize
		function resize() {

			// if fullscreen, do nothing (anchors.fill is set to parent, so sizing
			// is automatically handled)
			if (fullscreen === true) {
				return;
			}

			// if not, we'll need to get the size of the media to decide on how we should size the output
			const size = player.metaData && player.metaData.resolution ? player.metaData.resolution : null;
			if (size === null) {
				console.warning("Movie.resize called while player's metadata is not ready or does not contain the resolution.");
				return;
			}

			// make sure we don't grow bigger than our parent
			width = Math.min(size.width, root.width);
			height = Math.min(size.height, root.height);
		}

		// when the root is resized, we need to make sure the media is correctly resized
		Connections {
			target: root
			onWidthChanged: output.resize()
			onHeightChanged: output.resize()
		}

	}

	// the player
	MediaPlayer {
		id: player
		autoPlay: false
		loops: settings.get("Movie.Loop")
		muted: settings.get("Movie.Muted")
		volume: settings.get("Movie.Volume")
		notifyInterval: 2

		// on changes, update the settings
		onLoopsChanged: settings.set("Movie.Loop", loops)
		onMutedChanged: settings.set("Movie.Muted", muted)
		onVolumeChanged: settings.set("Movie.Volume", volume)

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

	// movie controls
	MovieControls {
		id: controls
		player: player
		output: output
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 10
		width: Math.min(700, parent.width - 50)
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
