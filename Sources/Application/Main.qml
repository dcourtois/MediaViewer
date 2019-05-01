import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.12
import MediaViewer 0.1


//
// The main window
//
Item {
	id: mainWindow

	// initialize
	Component.onCompleted: {

		// select the initial folder
		if (initFolder !== "") {
			folderBrowser.currentFolderPath = initFolder;
		}

		// if we have an initial media, select it and switch to fullscreen
		if (initMedia !== "") {
			selection.selectByPath(initMedia);
			if (selection.currentMedia) {
				rootView.fullscreen = true;
			} else {
				console.log(`initial media ${initMedia} not found`);
			}
		}

	}

	// reparent the mediaviewer on fullscreen state change
	Connections {
		target: rootView

		// on fullscreen changes, reparent the media viewer and update
		// the focus to have shortcuts working.
		onFullscreenChanged: {
			if (rootView.fullscreen === true) {
				mediaViewer.parent = mainWindow;
				mediaViewer.forceActiveFocus();
			} else {
				cursor.hidden = false;
				mediaViewer.parent = mediaViewerContainer;
				mediaBrowser.forceFocus();
			}
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

	// the preferences dialog
	Preferences {
		id: preferences
		mediaBrowser: mediaBrowser
		x: (mainWindow.width - width) / 2
		y: (mainWindow.height - height) / 2
	}

	//
	ColumnLayout {
		anchors.fill: parent
		spacing: 0

		// Menu
		MainMenu {
			Layout.fillWidth: true
			selection: selection
			preferences: preferences
		}

		// The split between the media preview and folder browser on the left,
		// and the media browser on the right
		SplitView {
			Layout.fillWidth: true
			Layout.fillHeight: true
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
					}
				}
			}

			// media browser
			MediaBrowser {
				id: mediaBrowser
				Layout.fillWidth: true
				selection: selection
			}
		}
	}

}
