import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import Qt.labs.settings 1.0
import MediaViewer 0.1


//
// The main window
//
ApplicationWindow {
	id: mainWindow

	visible: true

	// default size
	width: 1000
	height: 750

	//
	// Initialize
	//
	Component.onCompleted: {
		if (initFolder !== "") {
			folderBrowser.currentFolderPath = initFolder;
		}
		if (initMedia !== "") {
			mediaSelection.selectByPath(initMedia);
			stateManager.state = "fullscreen";
		}
	}

	//
	// Font
	//
	FontLoader {
		id: sourceSans
		property int size: 12		
		source: "qrc:///fonts/SourceSansPro-Regular"
	}

	//
	// Save the window's settings
	//
	WindowSettings {
		category: "MainWindow"
		window: mainWindow
	}

	//
	// default settings
	//
	Settings {
		id: settings
		property alias mediaViewerWidth: mediaViewer.width
		property alias mediaViewerHeight: mediaViewer.height
	}

	//
	// The models
	//
	FolderModel { id: folderModel; rootPaths: drives }
	MediaModel { id: mediaModel; root: folderBrowser.currentFolderPath }
	MediaSelection { id: mediaSelection; model: mediaModel }
	Connections { target: folderBrowser; onCurrentFolderPathChanged: mediaSelection.clear() }

	//
	// State manager
	//
	StateManager {
		id: stateManager
		mediaViewer: mediaViewer
		mediaBrowser: mediaBrowser
	}

	//
	// Menu
	//
	menuBar: MenuBar {
		Menu {
			title: "Edit"
			MenuItem {
				text: "Copy"
				shortcut: StandardKey.Copy
				enabled: mediaSelection.currentMedia !== null
				onTriggered: {
					fileSystem.copy([ mediaSelection.currentMedia.path ]);
					_sourceFolderPath = folderBrowser.currentFolderPath;
				}
			}
			MenuItem {
				text: "Cut"
				shortcut: StandardKey.Cut
				enabled: mediaSelection.currentMedia !== null
				onTriggered: {
					fileSystem.cut([ mediaSelection.currentMedia.path ]);
					_sourceFolderPath = folderBrowser.currentFolderPath;
				}
			}
			MenuItem {
				text: "Paste"
				shortcut: StandardKey.Paste
				enabled: fileSystem.canPaste
				onTriggered: {
					if (_sourceFolderPath !== folderBrowser.currentFolderPath) {
						fileSystem.paste(folderBrowser.currentFolderPath);
					}
				}
			}
			MenuItem {
				text: "Delete"
				shortcut: StandardKey.Delete
				enabled: mediaSelection.currentMedia !== null
				onTriggered: {
					// clear selection (AnimatedImage locks the file, preventing the deletion
					// to work) and remove the file
					var path = mediaSelection.currentMedia.path,
						index = mediaSelection.currentMediaIndex,
						hasNext = mediaSelection.hasNext();
					mediaSelection.clearCurrentIndex();
					fileSystem.remove([ path ]);
					
					// re-select the correct index
					if (hasNext === true) {
						mediaSelection.selectByIndex(index);
					} else if (index > 0) {
						mediaSelection.selectByIndex(index - 1);
					}
				}
			}
		}
		Menu {
			title: "Options"
			MenuItem {
				text: "Preferences"
				shortcut: StandardKey.Preferences
			}
		}
	}

	//
	// The split between the media preview and folder browser on the left,
	// and the media browser on the right
	//
	SplitView {
		anchors.fill: parent
		orientation: Qt.Horizontal

		//
		// split between the folders and the media preview
		//
		SplitView {
			orientation: Qt.Vertical

			//
			// folder view
			//
			FolderBrowser {
				id: folderBrowser
				Layout.fillHeight: true
				model: folderModel
			}

			//
			// media preview
			//
			MediaViewer {
				id: mediaViewer
				color: Qt.rgba(0, 0, 0, 1);
				selection: mediaSelection
				width: 300
				height: 300
			}
		}

		//
		// media browser
		//
		MediaBrowser {
			id: mediaBrowser
			Layout.fillWidth: true
			selection: mediaSelection
		}
	}

	// some privates
	property string _sourceFolderPath: ""
}
