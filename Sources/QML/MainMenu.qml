import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import MediaViewer 0.1


//
// The main menu
//
MenuBar {
	// externally set
	property var selection
	property var preferences
	property var slideShow

	Menu {
		id: fileMenu
		title: "File"

		// used to know wether we can paste or not
		property string _sourceFolder

		MenuItem {
			text: "Copy"
			enabled: selection.currentMedia !== undefined
			shortcut: StandardKey.Copy
			onTriggered: {
				fileSystem.copy(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		MenuItem {
			text: "Cut"
			enabled: selection.currentMedia !== undefined
			shortcut: StandardKey.Cut
			onTriggered: {
				fileSystem.cut(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}
		MenuItem {
			text: "Paste"
			enabled: fileSystem.canPaste && fileMenu._sourceFolder !== folderBrowser.currentFolderPath
			shortcut: StandardKey.Paste
			onTriggered: fileSystem.paste(folderBrowser.currentFolderPath)
		}

		MenuItem {
			text: "Delete"
			enabled: selection.currentMedia !== undefined
			shortcut: "Del"
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
		}

		MenuItem {
			text: "Close"
			shortcut: StandardKey.Quit
			onTriggered: Qt.quit();
		}
	}

	Menu {
		id: editMenu
		title: "Edit"

		MenuItem {
			text: "Select All"
			shortcut: "Ctrl+A"
			onTriggered: selection.selectAll();
		}
		MenuItem {
			text: "Select Inverse"
			enabled: selection.hasSelection() === true
			shortcut: "Ctrl+I"
			onTriggered: selection.selectInverse();
		}
		MenuItem {
			text: "Select None"
			enabled: selection.hasSelection() === true
			shortcut: "Ctrl+D"
			onTriggered: selection.clear();
		}
	}

	Menu {
		id: optionMenu
		title: "Options"

		MenuItem {
			text: "Slide Show"
			shortcut: "S"
			onTriggered: slideShow.start()
		}

		MenuSeparator {
		}

		MenuItem {
			text: "Preferences"
			shortcut: "Ctrl+Shift+P"
			onTriggered: preferences.open()
		}
	}
}
