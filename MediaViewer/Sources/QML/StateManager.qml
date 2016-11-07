import QtQuick 2.5


//
// Global state manager for the application.
//
Item {
	id: stateManager

	// the parts of the application
	property var mediaBrowser
	property var mediaViewer

	onMediaBrowserChanged: if (mediaBrowser) { mediaBrowser.stateManager = stateManager; }
	onMediaViewerChanged: if (mediaViewer) { mediaViewer.stateManager = stateManager; }

	//
	// The states
	//
	state: "preview"
	states: [
		State {
			name: "preview"
			PropertyChanges { target: mediaBrowser; focus: true }
		},
		State {
			name: "fullscreen"
			PropertyChanges { target: mediaBrowser; focus: false }
		}
	]
}
