import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


//
// The main menu
//
MenuBar {

	// externally set
	required property var selection
	required property var preferences

	background: Rectangle { opacity: 0 }

	component MenuItemEx : MenuItem {
		id: control

		// the API
		property alias sequence: shortcut.sequence
		property alias sequences: shortcut.sequences
		property int space: 10

		// replace the content to be able to display the shortcut sequence
		contentItem: RowLayout {
			Label { text: control.text }
			Item { Layout.fillWidth: true; Layout.minimumWidth: control.space }
			Label { text: shortcut.nativeText; enabled: false }
		}

		// shortcut
		Shortcut {
			id: shortcut
			enabled: parent.enabled
			context: Qt.ApplicationShortcut
			onActivated: control.triggered()
		}
	}


	Menu {
		title: "File"

		MenuItemEx {
			text: "Delete"
			enabled: selection.currentMedia !== undefined
			sequence: StandardKey.Delete
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

		MenuSeparator { }

		MenuItemEx {
			text: "Close"
			sequence: StandardKey.Close
			onTriggered: rootView.close()
		}
	}
	Menu {
		title: "Edit"

		MenuItemEx {
			text: "Copy"
			enabled: selection.currentMedia !== undefined
			sequence: StandardKey.Copy
			onTriggered: {
				fileSystem.copy(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}

		MenuItemEx {
			text: "Cut"
			enabled: selection.currentMedia !== undefined
			sequence: StandardKey.Cut
			onTriggered: {
				fileSystem.cut(selection.getSelectedPaths());
				fileMenu._sourceFolder = folderBrowser.currentFolderPath;
			}
		}

		MenuItemEx {
			text: "Paste"
			enabled: fileSystem && fileSystem.canPaste && fileMenu._sourceFolder !== folderBrowser.currentFolderPath
			sequence: StandardKey.Paste
			onTriggered: fileSystem.paste(folderBrowser.currentFolderPath)
		}

		MenuSeparator { }

		MenuItemEx {
			text: "Select All"
			sequence: StandardKey.SelectAll
			onTriggered: selection.selectAll();
		}

		MenuItemEx {
			text: "Select Inverse"
			enabled: selection.hasSelection() === true
			sequence: "Ctrl+I"
			onTriggered: selection.selectInverse();
		}

		MenuItemEx {
			text: "Select None"
			enabled: selection.hasSelection() === true
			sequence: "Ctrl+D"
			onTriggered: selection.clear();
		}

		MenuSeparator { }

		MenuItemEx {
			text: "Preferences"
			sequence: "Ctrl+Shift+P"
			onTriggered: preferences.open()
		}
	}
}
