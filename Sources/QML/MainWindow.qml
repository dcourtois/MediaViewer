import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import MediaViewer 0.1


//
// The main window. Will remember its state (windowed, maximized, and
// position / size) upon restart. Also provides functionalities to
// toggle an item in fullscreen and back.
//
ApplicationWindow {
	id: mainWindow
	visible: true

	// default size
	width: 1000
	height: 750

	// privates
	property int _lastVisibility
	property var _lastItemParent
	property var _fullScreenItem

	// set an item to fullscreen mode
	// call without any parameter to restore windowed mode
	function setFullScreen(item) {
		if (item !== undefined) {
			// backup data
			_fullScreenItem	= item;
			_lastItemParent	= item.parent;

			// update parent
			item.parent = fullscreenContent;

			// and toggle full screen
			_lastVisibility				= mainWindow.visibility;
			fullscreenWindow.visibility	= Window.FullScreen;
			visibility					= Window.Hidden;
		} else if (_fullScreenItem !== undefined ){
			// restore parent
			_fullScreenItem.parent = _lastItemParent;

			// reset data
			_fullScreenItem	= undefined;
			_lastItemParent	= undefined;

			// restore the windowed mode
			mainWindow.visibility		= _lastVisibility;
			fullscreenWindow.visibility	= Window.Hidden;
		}
	}

	// hande window state/position/size between sessions
	WindowSettings {
		category: "MainWindow"
		window: mainWindow
	}

	// the window used to display an item in fullscreen
	Window {
		id: fullscreenWindow
		visibility: Window.Hidden
		Rectangle {
			id: fullscreenContent
			anchors.fill: parent
		}
	}

}
