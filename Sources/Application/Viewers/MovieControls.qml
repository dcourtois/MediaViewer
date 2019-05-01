import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtMultimedia 5.8

import "../Components" as Components


//
// Movie controls. This control displays a rectangle with playback controls and
// seeking timeline.
//
Rectangle {
	id: root

	// externally set
	property var player

	// control the look & feel. Can be overriden
	property int iconSize: 32
	height: 80
	width: 500
	radius: 20
	color: Qt.rgba(0, 0, 0, 0.6)
	border.width: 4
	border.color: Qt.rgba(1, 1, 1, 0.6)

	// show the controls
	function show() {
		shouldHide = false;
		timer.restart();
	}

	// hide the controls
	function hide() {
		timer.stop();
		shouldHide = true;
	}

	// timer used to hide the controls when the cursor doesn't move for a given time
	Timer {
		id: timer
		interval: 1200
		onTriggered: root.shouldHide = true
	}

	// handle showing / hiding the controls
	property bool shouldHide: false
	property bool mouseOver: false
	enabled: mouseOver === true || shouldHide === false
	opacity: enabled ? 1 : 0
	Behavior on opacity { NumberAnimation { duration: 150 } }

	// handle the cursor
	onEnabledChanged: {
		if (rootView.fullscreen === true) {
			cursor.hidden = enabled === false;
		}
	}

	// set the movie at the given position
	function setPosition(position) {
		if (player.playbackState !== MediaPlayer.PlayingState) {
			player.play();
			player.pause();
		}
		player.seek(position);
	}

	// return time as a readable string. t is in milliseconds
	function formatTime(t) {
		var d = new Date(t),
			h = d.getUTCHours(),
			m = d.getUTCMinutes(),
			s = d.getSeconds();
		return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
	}

	// mouse area on the control to check if the mouse is inside or not
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		propagateComposedEvents: true
		onEntered: mouseOver = true
		onExited: mouseOver = false
	}

	// main layout
	ColumnLayout {
		anchors.fill: parent
		anchors.margins: 10
		spacing: 0

		// the controls
		Item {
			Layout.fillWidth: true
			height: root.iconSize

			RowLayout {
				anchors.centerIn: parent
				spacing: 10

				// stop
				Image {
					sourceSize { width: root.iconSize; height: root.iconSize }
					source: "qrc:/Icons/Stop"
					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.LeftButton
						onClicked: {
							root.setPosition(0);
							player.stop();
						}
					}
				}

				// play / pause
				Image {
					sourceSize { width: root.iconSize; height: root.iconSize }
					source: player.playbackState === MediaPlayer.PlayingState ? "qrc:/Icons/Pause" : "qrc:/Icons/Play"
					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.LeftButton
						onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
					}
				}

				// loop
				Image {
					sourceSize { width: root.iconSize; height: root.iconSize }
					source: "qrc:/Icons/Loop"
					opacity: player.loops === 1 ? 0.2 : 1
					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.LeftButton
						onClicked: player.loops = player.loops === 1 ? MediaPlayer.Infinite : 1
					}
				}

			}

			RowLayout {
				anchors.right: parent.right
				spacing: 10

				// volume icon
				Image {
					id: volumeIcon
					sourceSize { width: root.iconSize; height: root.iconSize }
					opacity: player.muted ? 0.2 : 1
					source: player.muted ? "qrc:/Icons/Mute" :  "qrc:/Icons/Sound"
					MouseArea {
						anchors.fill: parent
						acceptedButtons: Qt.LeftButton
						onClicked: player.muted = !player.muted
					}
				}

				// volume
				Components.ProgressBarEx {
					Layout.fillWidth: true
					Layout.preferredWidth: player.muted ? 0 : 80
					Layout.preferredHeight: root.iconSize
					Behavior on Layout.preferredWidth { NumberAnimation { duration: 100 } }
					enabled: player.muted === false
					visible: enabled
					interactive: enabled
					position: player.volume
					onPositionChanged: { player.volume = position; }
				}

			}

		}

		// seek bar
		RowLayout {
			spacing: 8

			// current time
			Text {
				color: Qt.rgba(1, 1, 1, 1)
				text: formatTime(player.position)
			}

			// seek bar
			Components.ProgressBarEx {
				Layout.fillWidth: true
				Layout.preferredHeight: root.iconSize
				interactive: true
				position: player.playbackState === MediaPlayer.StoppedState ? 0 : player.position / player.duration
				onPositionSet: root.setPosition(Math.round(position * player.duration))
			}

			// total time
			Text {
				color: Qt.rgba(1, 1, 1, 1)
				text: formatTime(player.duration)
			}

		}

	}
}
