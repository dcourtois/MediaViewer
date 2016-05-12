import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import QtQml.Models 2.2
import Qt.labs.settings 1.0
import MediaViewerLib 0.1


//
// The main window
//
Window {
	id: mainWindow

	visible: true

	//
	// Font
	//
	FontLoader {
		id: sourceSans;
		property int size: 12		
		source: "qrc:///fonts/SourceSansPro-Regular"
	}

	//
	// Save the window's settings
	//
	WindowSettings {
		category: "MainWindow"
		window: mainWindow
		width: 1000
		height: 750
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
	// Stater manager
	//
	StateManager {
		mediaViewer: mediaViewer
		mediaBrowser: mediaBrowser
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
}
