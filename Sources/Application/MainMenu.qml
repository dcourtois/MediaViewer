import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.0

import MediaViewer 0.1

import "Components" as Components


//
// The main menu
//
ToolBar {
	Material.elevation: 0

	// externally set
	property var selection
	property var preferences

	RowLayout {
		anchors.fill: parent

		//
		// File Menu
		//

		Components.ToolButtonEx {
			text: "Application"
			onClicked: appMenu.open()

			Menu {
				id: appMenu
				y: parent.y + parent.height

				Components.MenuItemEx {
					text: "Close"
					sequence: StandardKey.Close
					onTriggered: Qt.quit();
				}

				MenuSeparator {
				}

				Components.MenuItemEx {
					text: "Preferences"
					sequence: "Ctrl+Shift+P"
					onTriggered: preferences.open()
				}

			}

		}
		
		//
		// Edit Menu
		//

		Components.ToolButtonEx {
			id: editButton
			text: "Edit"
			onClicked: editMenu.open()

			Menu {
				id: editMenu
				y: parent.y + parent.height

				// used to know wether we can paste or not
				property string _sourceFolder

				Components.MenuItemEx {
					text: "Copy"
					enabled: selection.currentMedia !== undefined
					sequence: StandardKey.Copy
					onTriggered: {
						fileSystem.copy(selection.getSelectedPaths());
						fileMenu._sourceFolder = folderBrowser.currentFolderPath;
					}
				}

				Components.MenuItemEx {
					text: "Cut"
					enabled: selection.currentMedia !== undefined
					sequence: StandardKey.Cut
					onTriggered: {
						fileSystem.cut(selection.getSelectedPaths());
						fileMenu._sourceFolder = folderBrowser.currentFolderPath;
					}
				}

				Components.MenuItemEx {
					text: "Paste"
					enabled: fileSystem.canPaste && fileMenu._sourceFolder !== folderBrowser.currentFolderPath
					sequence: StandardKey.Paste
					onTriggered: fileSystem.paste(folderBrowser.currentFolderPath)
				}

				MenuSeparator {
				}

				Components.MenuItemEx {
					text: "Select All"
					sequence: StandardKey.SelectAll
					onTriggered: selection.selectAll();
				}

				Components.MenuItemEx {
					text: "Select Inverse"
					enabled: selection.hasSelection() === true
					sequence: "Ctrl+I"
					onTriggered: selection.selectInverse();
				}

				Components.MenuItemEx {
					text: "Select None"
					enabled: selection.hasSelection() === true
					sequence: StandardKey.Deselect
					onTriggered: selection.clear();
				}

				MenuSeparator {
				}

				Components.MenuItemEx {
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

			}
		}

		Item {
			Layout.fillWidth: true
		}

	}
}
