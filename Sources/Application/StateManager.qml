import QtQuick 2.5


//
// Global state manager for the application.
//
Item {
	// the parts of the application
	property var mediaBrowser
	property var mediaViewer
	property var mainWindow

	// note: I don't have any way of controlling the order of execution of the PropertyChanges,
	// ParentChange, etc. on a state change, so I don't use theme, and instead use onStateChanged
	state: "preview"
	states: [
		State { name: "preview" },
		State { name: "fullscreen" }
	]

	// utility to toggle the state betwen preview and full screen
	function toggleFullScreen() {
		state = state === "preview" ? "fullscreen" : "preview";
	}

	// state changes (see notes on state)
	onStateChanged: {
		if (state === "preview") {
			// toggle windowed
			mainWindow.setFullScreen();

			// restore focus
			mediaBrowser.forceFocus();

			// force cursor
			cursor.hidden = false;
		} else {
			// toggle fullscreen
			mainWindow.setFullScreen(mediaViewer);

			// backup focus and give it to the viewer
			mediaViewer.forceActiveFocus();
		}
	}
}
