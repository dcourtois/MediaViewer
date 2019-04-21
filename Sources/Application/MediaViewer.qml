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

	// default mouse handling
	MouseArea {
		anchors.fill: parent
		enabled: rootView.fullscreen
		acceptedButtons: Qt.LeftButton | Qt.MiddleButton

		// middle button click, toggle fullscreen
		onClicked: {
			if (mouse.button === Qt.MiddleButton) {
				rootView.fullscreen = !rootView.fullscreen;
			}
		}

		// double click: exit fullscreen
		onDoubleClicked: rootView.fullscreen = false

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
		// this should not happen
		if (rootView.fullscreen === false) {
			return;
		}

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
					rootView.fullscreen = !rootView.fullscreen;
				}
				break;

			// escape goes back to preview
			case Qt.Key_Escape:
				event.accepted = true;
				rootView.fullscreen = false;
				break;

			// default, froward to the viewer
			default:
				if (viewer.item !== null) {
					viewer.item.Keys.pressed(event);
				}
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

	// on selection change, update the viewer if needed
	Connections {
		target: selection
		onCurrentMediaChanged: {
			const type = selection.currentMedia ? selection.currentMedia.type : Media.NotSupported;
			if (viewer.item === null || viewer.item.mediaType !== type) {
				switch (type) {
					// Media.Image
					case 0:
						viewer.sourceComponent = image;
						break;

					// Media.Animated
					case 1:
						viewer.sourceComponent = animated;
						break;

					// Media.Movie
					case 2:
						viewer.sourceComponent = movie;
						break;

					// Media.NotSupported
					default:
						viewer.sourceComponent = undefined;
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

		// make selection available
		property var selection: root.selection
	}
}
