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

		// used to know wether we can paste or not
		property string _sourceFolder

		ShortcutMenuItem {
			text: "Copy"
			enabled: selection.currentMedia !== undefined
			sequence: "Ctrl+C"
			onTriggered: {
				fileSystem.copy(selection.getSelectedPaths());
				editMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			text: "Cut"
			enabled: selection.currentMedia !== undefined
			sequence: "Ctrl+X"
			onTriggered: {
				fileSystem.cut(selection.getSelectedPaths());
				editMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		ShortcutMenuItem {
			text: "Paste"
			enabled: fileSystem.canPaste && editMenu._sourceFolder !== folderBrowser.currentFolderPath
			sequence: "Ctrl+V"
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
