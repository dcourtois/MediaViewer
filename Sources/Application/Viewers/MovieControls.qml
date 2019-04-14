import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.8


//
// Movie controls. This control displays a rectangle with playback controls and
// seeking timeline.
//
Rectangle {
	id: root

	// externally set
	property var player

	// control the look & feel. Can be overriden
	height: 100
	width: 500
	radius: 20
	color: Qt.rgba(0, 0, 0, 0.6)
	border.width: 2
	border.color: Qt.rgba(1, 1, 1, 0.6)

	// set the movie at the given position
	function setPosition(position) {
		player.seek(position);
		if (player.playbackState !== MediaPlayer.PlayingState) {
			player.play();
			player.pause();
		}
	}

	// return time as a readable string. t is in milliseconds
	function formatTime(t) {
		var d = new Date(t),
			h = d.getUTCHours(),
			m = d.getUTCMinutes(),
			s = d.getSeconds();
		return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
	}

	// main layout
	ColumnLayout {
		anchors.fill: parent
		anchors.margins: 10

		// the controls
		RowLayout {
			spacing: 10

			// to center
			Item {
				Layout.fillWidth: true
			}

			// stop
			Image {
				sourceSize { width: 40; height: 40 }
				source: "qrc:/Icons/Stop"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: {
						player.stop();
						root.setPosition(0);
					}
				}
			}

			// play / pause
			Image {
				sourceSize { width: 40; height: 40 }
				source: player.playbackState === MediaPlayer.PlayingState ? "qrc:/Icons/Pause" : "qrc:/Icons/Play"
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
				}
			}

			// loop
			Image {
				id: loop
				sourceSize { width: 40; height: 40 }
				source: "qrc:/Icons/Loop"
				opacity: player.loops === 1 ? 0.2 : 1
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: player.loops = player.loops === 1 ? MediaPlayer.Infinite : 1
				}
			}

			// to center
			Item {
				Layout.fillWidth: true
			}

		}

		// seek bar
		RowLayout {
			Layout.leftMargin: 10
			Layout.rightMargin: 10

			// current time
			Text {
				color: Qt.rgba(1, 1, 1, 1)
				text: formatTime(player.position)
			}

			// seek bar
			Item {
				Layout.fillWidth: true
				height: 30

				ProgressBar {
					id: seekBar
					anchors.fill: parent
				
					from: 0
					value: player.position
					to: player.duration
				}

				MouseArea {
					anchors.fill: parent
					onClicked: root.setPosition(player.duration * Math.min(player.duration, Math.max(0, (mouse.x / width))))
					onPositionChanged: root.setPosition(player.duration * Math.min(player.duration, Math.max(0, (mouse.x / width))))
				}
			}

			// total time
			Text {
				color: Qt.rgba(1, 1, 1, 1)
				text: formatTime(player.duration)
			}

		}

	}
}
