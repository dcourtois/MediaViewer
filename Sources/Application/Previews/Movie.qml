import QtQuick 2.5
import QtMultimedia 5.8


//
// Video preview item
//
Item {
	// the output
	VideoOutput {
		id: output
		anchors.fill: parent
		source: player
		autoOrientation: true
	}

	// the player
	MediaPlayer {
		id: player
		source: "file:///" + parent.sourcePath
		loops: MediaPlayer.Infinite
		muted: true
		onStatusChanged: {
			if (status === MediaPlayer.Loaded) {
				player.seek(100);
				player.play();
				player.pause();
			}
		}
	}

	// privates
	property bool _mouseHover: false

	// to detect mouse hover
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: parent._mouseHover = true
		onExited: parent._mouseHover = false
	}
}
