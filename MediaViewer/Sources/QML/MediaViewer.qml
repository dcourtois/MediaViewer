import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtMultimedia 5.6


//
// Media view
//
Rectangle {
	id: root

	// externally set
	property var selection
	property var stateManager

	//
	// fullscreen / preview states
	//
	state: stateManager ? stateManager.state : "preview"
	states: [
		State {
			name: "fullscreen"
			ParentChange { target: image; parent: fullScreenItem }
			ParentChange { target: animatedImage; parent: fullScreenItem }
			ParentChange { target: movie; parent: fullScreenItem }
		},
		State {
			name: "preview"
			ParentChange { target: image; parent: root }
			ParentChange { target: animatedImage; parent: root }
			ParentChange { target: movie; parent: root }
		}
	]

	//
	// The window that's used to display the media in fullscreen
	//
	Window {
		id: fullScreenWindow

		// configure
		color: root.color
		flags: Qt.SplashScreen
		visible: root.state === "fullscreen" ? true : false
		visibility: root.state === "fullscreen" ? Window.FullScreen : Window.Hidden
		width: Screen.width
		height: Screen.height

		// when the window is no longer active, revert into the preview state
		onActiveChanged: if (active === false) { stateManager.state = "preview"; }

		// quit the main application when the user closes the window in fullscreen mode
		// (by default, it will only close the fullscreen window, leaving the application
		// in a broken state)
		onClosing: {
			close.accepted = true;
			Qt.quit();
		}

		//
		// The content item (we can't use the window as a parent in a
		// ParentChange state change)
		//
		Rectangle {
			id: fullScreenItem
			color: fullScreenWindow.color
			anchors.fill: parent
		}
	}

	//
	// The static image viewer
	//
	ImageViewer {
		id: image
		anchors.fill: parent
		selection: root.selection
		stateManager: root.stateManager
	}

	//
	// The animated image viewer
	//
	AnimatedImageViewer {
		id: animatedImage
		anchors.fill: parent
		selection: root.selection
		stateManager: root.stateManager
	}

	//
	// The movie viewer
	//
	MovieViewer {
		id: movie
		anchors.fill: parent
		selection: root.selection
		stateManager: root.stateManager
	}
}
