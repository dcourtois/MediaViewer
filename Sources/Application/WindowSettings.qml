import QtQuick 2.3
import QtQuick.Window 2.2


//
// This component will save and restore the states of a Window
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

	// current and previous states. These are needed because the
	// visibility state changes after the position and size of the window
	// changes, so we need to keep track of the previous states
	QtObject {
		id: previous
		property int x
		property int y
		property int width
		property int height
		property bool maximized
	}
	QtObject {
		id: current
		property int x
		property int y
		property int width
		property int height
		property bool maximized
	}

	// post-constructor. Initialize the window states
	Component.onCompleted: {
		// init settings
		settings.init("MainWindow.X", window.x);
		settings.init("MainWindow.Y", window.x);
		settings.init("MainWindow.Width", window.width);
		settings.init("MainWindow.Height", window.height);
		settings.init("MainWindow.Maximized", window.visibility === Window.Maximized);

		// restore settings
		previous.x = current.x = settings.get("MainWindow.X")
		previous.y = current.y = settings.get("MainWindow.Y")
		previous.width = current.width = settings.get("MainWindow.Width");
		previous.height = current.height = settings.get("MainWindow.Height");
		previous.maximized = current.maximized = settings.get("MainWindow.Maximized");
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
			} else if (window.visibility === Window.Hidden) {
				// Save settings.
				settings.set("MainWindow.X", current.maximized ? previous.x : current.x);
				settings.set("MainWindow.Y", current.maximized ? previous.y : current.y);
				settings.set("MainWindow.Width", current.maximized ? previous.width : current.width);
				settings.set("MainWindow.Height", current.maximized ? previous.height : current.height);
				settings.set("MainWindow.Maximized", current.maximized);
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
