import QtQuick 2.3
import QtQuick.Window 2.2
import Qt.labs.settings 1.0


//
// This component will save and restore the states
// of a Window
//
Item {
	id: root

	// the window (must be set by the user)
	property Window window

	// the settings category
	property string category: "Window"

	// default maximized state
	property bool maximized: false

	//-------------------------------------------------------------------------
	// The following is private, do not modify externally

	// the settings
	Settings {
		id: settings
		category: root.category
		property int x
		property int y
		property int width
		property int height
		property bool maximized
	}

	// current and previous states. These are needed because the
	// visibility state changes after the position and size of the window
	// changes, so we need to keep track of the previous states
	WindowState { id: previous }
	WindowState { id: current }

	// post-constructor. Initialize the window states
	Component.onCompleted: {
		if (!settings.width || !settings.height) {
			// First run, or width/height are screwed up.
			current.x = window.x;
			current.y = window.y;
			current.width = window.width;
			current.height = window.height;
			current.maximized = false;
		} else {
			current.x = settings.x;
			current.y = settings.y;
			current.width = settings.width;
			current.height = settings.height;
			current.maximized = settings.maximized
		}

		window.x = previous.x = current.x;
		window.y = previous.y = current.y;
		window.width = previous.width = current.width;
		window.height = previous.height = current.height;

		if (current.maximized) {
			window.visibility = Window.Maximized;
		}
	}

	// watch for states modifications
	Connections {
		target: window

		onVisibilityChanged: {
			if (window.visibility === Window.Maximized) {
				// Ignore the latest values that correspond to the maximized states.
				current.maximized = true;
				current.x = previous.x;
				current.y = previous.y;
				current.width = previous.width;
				current.height = previous.height;
			} else if (window.visibility === Window.Windowed) {
				// Update states
				current.maximized = false;
				current.x = previous.x = window.x;
				current.y = previous.y = window.y;
				current.width = previous.width = window.width;
				current.height = previous.height = window.height;
			}
			else if (window.visibility === Window.Hidden) {
				// Save settings.
				settings.x = current.maximized ? previous.x : current.x;
				settings.y = current.maximized ? previous.y : current.y;
				settings.width = current.maximized ? previous.width : current.width;
				settings.height = current.maximized ? previous.height : current.height;
				settings.maximized = current.maximized;
			}
		}

		onXChanged: {
			if (window.x !== current.x) {
				previous.x = current.x;
				current.x = window.x;
			}
		}

		onYChanged: {
			if (window.y !== current.y) {
				previous.y = current.y;
				current.y = window.y;
			}
		}

		onWidthChanged: {
			if (window.width !== current.width) {
				previous.width = current.width;
				current.width = window.width;
			}
		}

		onHeightChanged: {
			if (window.height !== current.height) {
				previous.height = current.height;
				current.height = window.height;
			}
		}
	}
}