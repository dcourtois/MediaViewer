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

	// externally set
	property var selection

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

		ShortcutMenuItem {
			id: copy
			text: "Copy"
			enabled: selection.currentMedia !== undefined
			sequence: "Ctrl+C"
			onTriggered: {
				fileSystem.copy([ selection.currentMedia.path ]);
				_sourceFolderPath = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			id: cut
			text: "Cut"
			enabled: selection.currentMedia !== undefined
			sequence: "Ctrl+X"
			onTriggered: {
				fileSystem.cut([ selection.currentMedia.path ]);
				_sourceFolderPath = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			id: paste
			text: "Paste"
			enabled: fileSystem.canPaste
			sequence: "Ctrl+V"
			onTriggered: {
				if (_sourceFolderPath !== folderBrowser.currentFolderPath) {
					fileSystem.paste(folderBrowser.currentFolderPath);
				}
			}
		}
		ShortcutMenuItem {
			id: del
			text: "Delete"
			enabled: selection.currentMedia !== undefined
			sequence: "Del"
			onTriggered: {
				// clear selection (AnimatedImage locks the file, preventing the deletion
				// to work) and remove the file
				var path = selection.currentMedia.path,
					index = selection.currentMediaIndex,
					hasNext = selection.hasNext();
				selection.clearCurrentIndex();
				fileSystem.remove([ path ]);

				// re-select the correct index
				if (hasNext === true) {
					selection.selectByIndex(index);
				} else if (index > 0) {
					selection.selectByIndex(index - 1);
				}
			}
		}
	}

	Menu {
		id: optionMenu
		x: optionButton.x
		y: optionButton.y + optionButton.height
		width: 250

		ShortcutMenuItem {
			text: "Preferences"
			sequence: "Ctrl+Shift+P"
			onTriggered: preferences.open()
		}
	}
}
