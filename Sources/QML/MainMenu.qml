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
	property var preferences
	property var slideShow

	RowLayout {
		anchors.fill: parent
		ToolButton {
			id: fileButton
			text: "File"
			onClicked: fileMenu.visible ? fileMenu.close() : fileMenu.open()
		}
		ToolButton {
			id: editButton
			text: "Edit"
			onClicked: editMenu.visible ? editMenu.close() : editMenu.open()
		}
		ToolButton {
			id: optionButton
			text: "Options"
			onClicked: optionMenu.visible ? optionMenu.close() : optionMenu.open()
		}
		Item {
			Layout.fillWidth: true
		}
	}

	Menu {
		id: fileMenu
		x: fileButton.x
		y: fileButton.y + fileButton.height

		// used to know wether we can paste or not
		property string _sourceFolder

		ShortcutMenuItem {
			text: "Copy"
			enabled: selection.currentMedia !== undefined
			sequence: StandardKey.Copy
			onTriggered: {
				fileSystem.copy(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			text: "Cut"
			enabled: selection.currentMedia !== undefined
			sequence: StandardKey.Cut
			onTriggered: {
				fileSystem.cut(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			text: "Paste"
			enabled: fileSystem.canPaste && fileMenu._sourceFolder !== folderBrowser.currentFolderPath
			sequence: StandardKey.Paste
			onTriggered: fileSystem.paste(folderBrowser.currentFolderPath)
		}

		ShortcutMenuItem {
			text: "Delete"
			enabled: selection.currentMedia !== undefined
			sequence: "Del"
			onTriggered: {
				// collect paths
				var paths = selection.getSelectedPaths();

				// handle selection behavior after a deletion, because the
				// view does a really crappy job at that.
				// In the case of multiple selection, it's a lot trickier, so
				// only handle single selection for now.
				if (paths.length === 1) {
					var index = selection.current.row,
						path = selection.currentMedia.path,
						hasNext = selection.hasNext();

					// select the next one if needed
					if (hasNext === true) {
						selection.setCurrent(index + 1);
					} else if (index > 0){
						selection.setCurrent(index - 1);
					} else {
						selection.clear();
					}
				} else {
					selection.clear();
				}

				// remove
				fileSystem.remove(paths);
			}
		}

		MenuSeparator {
			x: 15
			width: 220
		}

		ShortcutMenuItem {
			text: "Close"
			sequence: StandardKey.Quit
			onTriggered: Qt.quit();
		}
	}

	Menu {
		id: editMenu
		x: editButton.x
		y: editButton.y + editButton.height

		ShortcutMenuItem {
			text: "Select All"
			sequence: "Ctrl+A"
			onTriggered: selection.selectAll();
		}
		ShortcutMenuItem {
			text: "Select Inverse"
			enabled: selection.hasSelection() === true
			sequence: "Ctrl+I"
			onTriggered: selection.selectInverse();
		}
		ShortcutMenuItem {
			text: "Select None"
			enabled: selection.hasSelection() === true
			sequence: "Ctrl+D"
			onTriggered: selection.clear();
		}
	}

	Menu {
		id: optionMenu
		x: optionButton.x
		y: optionButton.y + optionButton.height
		width: 250

		ShortcutMenuItem {
			text: "Slide Show"
			sequence: "S"
			onTriggered: slideShow.start()
		}

		MenuSeparator {
			x: 15
			width: 220
		}

		ShortcutMenuItem {
			text: "Preferences"
			sequence: "Ctrl+Shift+P"
			onTriggered: preferences.open()
		}
	}
}
