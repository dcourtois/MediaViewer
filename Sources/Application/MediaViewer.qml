import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

import MediaViewer 0.1

import "Viewers" as Viewers


//
// Media view
//
Rectangle {
	id: root

	// always fill parent
	anchors.fill: parent

	// externally set
	property var selection
	property var stateManager

	// default mouse handling
	MouseArea {
		anchors.fill: parent
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton

		// middle button click, toggle fullscreen
		onClicked: {
			if (selection.currentMedia && mouse.button === Qt.MiddleButton) {
				stateManager.toggleFullScreen();
			}
		}

		// double click: toggle fullscreen state
		onDoubleClicked: {
			if (selection.currentMedia) {
				stateManager.toggleFullScreen();
			}
		}

		// mouse wheel, image navigation
		onWheel: {
			if (wheel.angleDelta.y > 0) {
				selection.selectPrevious();
			} else {
				selection.selectNext();
			}
		}
	}

	// default key handling
	Keys.onPressed: {
		switch (event.key) {
			// previous media
			case Qt.Key_Left:
			case Qt.Key_Up:
				event.accepted = true;
				selection.selectPrevious();
				break;

			// next media
			case Qt.Key_Right:
			case Qt.Key_Down:
				event.accepted = true;
				selection.selectNext();
				break;

			// enter toggles full screen
			case Qt.Key_Return:
			case Qt.Key_Enter:
				event.accepted = true;
				if (selection.currentMedia) {
					stateManager.toggleFullScreen();
				}
				break;

			// escape goes back to preview
			case Qt.Key_Escape:
				event.accepted = true;
				stateManager.state = "preview";
				break;

			default:
				event.accepted = false;
		}
	}

	// update focus
	function updateFocus() {
		if (selection.currentMedia) {
			var isFullScreen = stateManager.state === "fullscreen";
			root.focus = isFullScreen;
			viewer.focus = isFullScreen;
		}
	}

	// the animated image viewer
	Component {
		id: animated
		Viewers.Animated {
			readonly property var mediaType: Media.Animated
			source: "file:///" + selection.currentMedia.path
		}
	}

	// the image viewer
	Component {
		id: image
		Viewers.Image {
			readonly property var mediaType: Media.Image
			source: "file:///" + selection.currentMedia.path
		}
	}

	// the movie viewer
	Component {
		id: movie
		Viewers.Movie {
			readonly property var mediaType: Media.Movie
			source: "file:///" + selection.currentMedia.path
		}
	}

	// handle focus for the movie viewer
	Connections { target: stateManager; onStateChanged: updateFocus() }
	Connections { target: selection; onCurrentMediaChanged: updateFocus() }

	// on selection change, update the viewer if needed
	Connections {
		target: selection
		onCurrentMediaTypeChanged: {
			const type = selection.currentMedia ? selection.currentMedia.type : Media.NotSupported;
			if (viewer.item === null || type !== viewer.item.mediaType) {
				switch (type) {
					case Media.Animated:
						viewer.sourceComponent = animated;
						break;
					case Media.Image:
						viewer.sourceComponent = image;
						break;
					case Media.Movie:
						viewer.sourceComponent = movie;
						break;
				}
			}
		}
	}

	// the content
	Loader {
		id: viewer
		asynchronous: false
		anchors.fill: parent

		// make selection and state manager available
		property var selection: root.selection
		property var stateManager: root.stateManager
	}
}
