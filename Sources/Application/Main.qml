import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import MediaViewer 0.1


//
// The main window
//
MainWindow {
	id: mainWindow
	title: selection.currentMedia ? "Media Viewer - " + selection.currentMedia.path : "Media Viewer"

	// initialize starting folders
	Component.onCompleted: {
		if (initFolder !== "") {
			folderBrowser.currentFolderPath = initFolder;
		}
		if (initMedia !== "") {
			selection.selectByPath(initMedia);
			stateManager.state = "fullscreen";
		}
	}

	// the folder model. Allow access to the physical folders.
	FolderModel {
		id: folderModel
		rootPaths: drives
	}

	// the media  model. Allow access to the medias in the current folder.
	MediaModel {
		id: mediaModel
		root: folderBrowser.currentFolderPath
	}

	// global media selection (needed to share selection between the
	// media browser and the media preview)
	Selection {
		id: selection
		model: mediaModel
	}

	// connect the media selection and the folder browser
	Connections {
		target: folderBrowser
		onCurrentFolderPathChanged: selection.clear()
	}

	// global state manager. Used to control fullscren/browsing mode
	StateManager {
		id: stateManager
		mediaBrowser: mediaBrowser
		mediaViewer: mediaViewer
		mainWindow: mainWindow
	}

	// the slide show
	SlideShow {
		id: slideShow
		stateManager: stateManager
		selection: selection
		_mediaViewer: mediaViewer
	}

	// the preferences dialog
	Preferences {
		id: preferences
		mediaBrowser: mediaBrowser
		x: (mainWindow.width - width) / 2
		y: (mainWindow.height - height) / 2
	}

	// Menu
	menuBar: MainMenu {
		selection: selection
		preferences: preferences
		slideShow: slideShow
	}

	// The split between the media preview and folder browser on the left,
	// and the media browser on the right
	SplitView {
		anchors.fill: parent
		orientation: Qt.Horizontal

		// split between the folders and the media preview
		SplitView {
			orientation: Qt.Vertical

			// folder view
			FolderBrowser {
				id: folderBrowser
				Layout.fillHeight: true
				model: folderModel
			}

			// media preview
			Item {
				id: mediaViewerContainer
				width: settings.get("MediaView.Preview.Width", 300)
				height: settings.get("MediaView.Preview.Height", 300)

				onWidthChanged: settings.set("MediaView.Preview.Width", width)
				onHeightChanged: settings.set("MediaView.Preview.Height", height)

				MediaViewer {
					id: mediaViewer
					color: Qt.rgba(0, 0, 0, 1);
					selection: selection
					stateManager: stateManager
				}
			}
		}

		// media browser
		MediaBrowser {
			id: mediaBrowser
			Layout.fillWidth: true
			selection: selection
			stateManager: stateManager
		}
	}
}
