import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
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

	// default settings
	Settings {
		id: settings

		// size of the viewer part
		property alias mediaViewerWidth: mediaViewerContainer.width
		property alias mediaViewerHeight: mediaViewerContainer.height
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
		settings: preferences.settings
		stateManager: stateManager
		selection: selection
		_mediaViewer: mediaViewer
	}

	// the preferences dialog
	Preferences {
		id: preferences
		mediaBrowser: mediaBrowser
		settings: Settings {
			category: "Preferences"
			property int playAnimatedImages: 2
			property int playMovies: 2
			property int sortBy: 4
			property int sortOrder: 0
			property double thumbnailSize: 0.5
			property string lastVisitedFolder: ""
			property bool restoreLastVisitedFolder: false
			property bool deletePermanently: false
			property bool showLabel: false
			property int slideShowDelay: 2500
			property bool slideShowLoop: true
			property bool slideShowSelection: false
		}
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
				settings: preferences.settings
			}

			// media preview
			Item {
				id: mediaViewerContainer
				width: 300
				height: 300

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
			settings: preferences.settings
		}
	}
}
