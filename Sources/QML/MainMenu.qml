import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.0
import MediaViewer 0.1


//
// The main menu
//
ToolBar {
	Material.background: Material.BlueGrey
	Material.elevation: 0

	RowLayout {
		anchors.fill: parent
		ToolButton {
			id: editButton
			text: "Edit"
			onClicked: editMenu.open()
		}
		ToolButton {
			id: optionButton
			text: "Options"
			onClicked: optionMenu.open()
		}
		Item {
			Layout.fillWidth: true
		}
	}

	Menu {
		id: editMenu
		x: editButton.x
		y: editButton.y + editButton.height

		MenuItem {
			id: copy
			text: "Copy"
			enabled: mediaSelection.currentMedia !== null
			Shortcut {
				enabled: copy.enabled
				sequence: "Ctrl+C"
				context: Qt.ApplicationShortcut
				onActivated: copy.triggered()
			}
			onTriggered: {
				fileSystem.copy([ mediaSelection.currentMedia.path ]);
				_sourceFolderPath = folderBrowser.currentFolderPath;
			}
		}
		MenuItem {
			id: cut
			text: "Cut"
			enabled: mediaSelection.currentMedia !== null
			Shortcut {
				enabled: cut.enabled
				sequence: "Ctrl+X"
				context: Qt.ApplicationShortcut
				onActivated: cut.triggered()
			}
			onTriggered: {
				fileSystem.cut([ mediaSelection.currentMedia.path ]);
				_sourceFolderPath = folderBrowser.currentFolderPath;
			}
		}
		MenuItem {
			id: paste
			text: "Paste"
			enabled: fileSystem.canPaste
			Shortcut {
				enabled: paste.enabled
				sequence: "Ctrl+V"
				context: Qt.ApplicationShortcut
				onActivated: paste.triggered()
			}
			onTriggered: {
				if (_sourceFolderPath !== folderBrowser.currentFolderPath) {
					fileSystem.paste(folderBrowser.currentFolderPath);
				}
			}
		}
		MenuItem {
			id: del
			text: "Delete"
			enabled: mediaSelection.currentMedia !== null
			Shortcut {
				enabled: del.enabled
				sequence: "Del"
				context: Qt.ApplicationShortcut
				onActivated: del.triggered()
			}
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
		id: optionMenu
		x: optionButton.x
		y: optionButton.y + optionButton.height

		MenuItem {
			text: "Preferences"
			Shortcut {
				sequence: "Ctrl+Shift+P"
				context: Qt.ApplicationShortcut
				onActivated: preferences.open()
			}
			onTriggered: preferences.open()
		}
	}
}
