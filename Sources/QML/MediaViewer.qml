import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import MediaViewer 0.1


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
		acceptedButtons: Qt.LeftButton

		// double click: toggle fullscreen state
		onDoubleClicked: if (selection.currentMedia) { stateManager.toggleFullScreen(); }
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

	// detect media changes
	Connections {
		target: selection
		onCurrentMediaChanged: {
			if (selection.currentMedia) {
				switch (selection.currentMedia.type) {
					case Media.Image:
						viewer.sourceComponent = image;
						viewer.item.source = "file:///" + selection.currentMedia.path;
						break;

					case Media.AnimatedImage:
						viewer.sourceComponent = animatedImage;
						viewer.item.source = "file:///" + selection.currentMedia.path;
						break;

					case Media.Movie:
						viewer.sourceComponent = movie;
						viewer.item.source = "file:///" + selection.currentMedia.path;
						break;

					case Media.NotSupported:
						viewer.sourceComponent = undefined;
						break;
				}
			} else {
				viewer.sourceComponent = undefined;
			}
		}
	}

	// set the focus to the correct item, depending on the various states
	// of the viewer.
	function updateFocus() {
		// do nothing when no selection
		if (selection.currentMedia === undefined) {
			return;
		}

		var isFullScreen = stateManager.state === "fullscreen";

		// check if the current media is a movie or not
		if (selection.currentMedia.type === Media.Movie) {
			root.focus = isFullScreen;
			viewer.focus = isFullScreen;
		} else {
			viewer.focus = false;
			root.focus = isFullScreen;
		}
	}

	// handle focus for the movie viewer
	Connections { target: stateManager; onStateChanged: updateFocus() }
	Connections { target: selection; onCurrentMediaChanged: updateFocus() }

	// the content
	Loader {
		id: viewer
		asynchronous: false
		anchors.fill: parent
	}

	// The static image viewer
	Component {
		id: image
		ImageViewer {
			selection: root.selection
			stateManager: root.stateManager
		}
	}

	// The animated image viewer
	Component {
		id: animatedImage
		AnimatedImageViewer {
			selection: root.selection
			stateManager: root.stateManager
		}
	}

	// The movie viewer
	Component {
		id: movie
		MovieViewer {
			selection: root.selection
			stateManager: root.stateManager
		}
	}
}
