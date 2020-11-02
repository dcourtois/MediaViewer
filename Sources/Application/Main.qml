import QtQuick 2.15
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import MediaViewer 0.1


//
// The main window
//
FramelessWindow {
	id: mainWindow

	// get a few colors
	readonly property color highlight: Material.accent

	// true when the application is viewing a single media
	property bool fullscreenView: false

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
				fullscreenView = true;
			} else {
				console.log(`initial media ${initMedia} not found`);
			}
		}
	}

	// backups
	property var backup: QtObject {
		property int headerHeight
		property bool maximized
	}

	// on fullscreen view change, update the layout
	onFullscreenViewChanged: {
		if (fullscreenView === true) {
			// first, go to maximized
			backup.maximized = rootView.maximized;
			rootView.maximized = true;

			// disable the header
			backup.headerHeight = headerHeight;
			headerHeight = 0;

			// reparent the media viewer and give it focus
			mediaViewer.parent = mainContainer;
			mediaViewer.forceActiveFocus();
		} else {
			// restore the states
			rootView.maximized = backup.maximized;
			headerHeight = backup.headerHeight;

			// show the cursor
			cursor.hidden = false;

			// reparent the media viewer and give focus to the media browser
			mediaViewer.parent = mediaViewerContainer;
			mediaBrowser.forceFocus();
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
		function onCurrentFolderPathChanged() { selection.clear(); }
	}

	// the preferences dialog
	Preferences {
		id: preferences
		mainWindow: mainWindow
		mediaBrowser: mediaBrowser
		x: (mainWindow.width - width) / 2
		y: (mainWindow.height - height) / 2
		Material.theme: mainWindow.Material.theme
		Material.accent: mainWindow.Material.accent
	}

	// the main menu
	menu: MainMenu {
		id: menu
		selection: selection
		preferences: preferences
	}

	// application title
	title: Label {
		id: title
		text: selection.currentMedia !== undefined ? `MediaViewer - ${selection.currentMedia.name}` : "MediaViewer"
		anchors.fill: parent
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	// main split view (between the media browsers on the right and the folder + preview on the left)
	// note that the root Item is used to reparent the media viewer because we can't parent to a placeholder directly.
	content: Item {
		id: mainContainer
		anchors.fill: parent

		Controls.SplitView {
			id: horizontalSplit
			anchors.fill: parent
			orientation: Qt.Horizontal

			// split between the folders and the media preview
			Controls.SplitView {
				id: verticalSplit
				orientation: Qt.Vertical

				// folder view
				FolderBrowser {
					id: folderBrowser
					Layout.fillHeight: true
					mainWindow: mainWindow
					model: folderModel
				}

				// media preview
				Item {
					id: mediaViewerContainer
					width: settings.get("MediaView.Preview.Width", 400)
					height: settings.get("MediaView.Preview.Height", 500)

					onWidthChanged: settings.set("MediaView.Preview.Width", width)
					onHeightChanged: settings.set("MediaView.Preview.Height", height)

					MediaViewer {
						id: mediaViewer
						color: Qt.rgba(0, 0, 0, 1)
						mainWindow: mainWindow
						selection: selection
					}
				}
			}

			// media browser
			MediaBrowser {
				id: mediaBrowser
				Layout.fillWidth: true
				mainWindow: mainWindow
				selection: selection
			}
		}
	}
}
