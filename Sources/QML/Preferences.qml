import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as PlatformDialog
import MediaViewer 0.1


Dialog {
	id: root
	title: "Preferences"
	standardButtons: Dialog.Ok
	width: 600
	height: 400

	// externally set
	property var mediaBrowser
	property var settings

	// private properties
	property int _labelWidth: Math.max(root.width / 3, 200)

	// restore the previous focus item on hiding
	onVisibleChanged: {
		if (visible === false) {
			mediaBrowser.forceFocus();
		}
	}

	ColumnLayout {
		id: column
		anchors.fill: parent

		// tab bar header
		TabBar {
			id: bar
			width: parent.width

			TabButton {
				width: column.width / 4
				text: "General"
			}

			TabButton {
				width: column.width / 4
				text: "Interface"
			}

			TabButton {
				width: column.width / 4
				text: "Slide Show"
			}

			TabButton {
				width: column.width / 4
				text: "Cache"
			}
		}

		// tabs content
		StackLayout {
			width: parent.width
			currentIndex: bar.currentIndex

			// general options
			ColumnLayout {

				// Remmber last visited folder
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Remember Last Visited Folder"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: restoreLastVisitedFolder
						onCheckedChanged: {
							if (root.visible === true) {
								settings.restoreLastVisitedFolder = checked
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"If checked, when reopened the viewer will restore\n" +
									"its last visited folder.";
						}
					}
				}

				// Delete permanently
				RowLayout {
					spacing: 10
					enabled: fileSystem.canTrash
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Delete Permanently"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: deletePermanently
						onCheckedChanged: {
							if (root.visible === true) {
								settings.deletePermanently = checked
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"If your platform supports trashing things, you\n" +
									"can use this setting to control wether deleting\n" +
									"something will move it to the trash or delete it.";
						}
					}
				}

				// fill the remaining space
				Item {
					Layout.fillHeight: true
					Layout.columnSpan: 2
				}
			}

			// interface options
			ColumnLayout {

				// Sort by
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Sort By"
						horizontalAlignment: Text.AlignRight
					}
					ComboBox {
						id: sortBy
						Layout.fillWidth: true
						model: [
							"Name",
							"Size",
							"Date",
							"Type",
							"None"
						]
						onCurrentIndexChanged: {
							if (root.visible === true) {
								settings.sortBy = currentIndex
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Select the sorting criteria. None will disable sort,\n" +
									"and the order will be undefined.";
						}
					}
				}

				// Sort order
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Sort Order"
						horizontalAlignment: Text.AlignRight
					}
					ComboBox {
						id: sortOrder
						Layout.fillWidth: true
						model: [
							"Ascending",
							"Descending"
						]
						onCurrentIndexChanged: {
							if (root.visible === true) {
								settings.sortOrder = currentIndex
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"For a given sort criteria, sort by ascending or descending order.";
						}
					}
				}

				// Browser thumbnails size in pixels
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Thumbnail Size"
						horizontalAlignment: Text.AlignRight
					}
					Slider {
						id: thumbnailSize
						Layout.fillWidth: true
						onValueChanged: settings.thumbnailSize = value
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Control the size of the thumbnails in the media browser view.";
						}
					}
				}

				// Show image names in the browser
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Show Labels"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: showLabel
						onCheckedChanged: {
							if (root.visible === true) {
								settings.showLabel = checked
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"If checked, will display the name of the medias under\n" +
									"the thumbnails in the media browser view.";
						}
					}
				}

				// fill the remaining space
				Item {
					Layout.fillHeight: true
					Layout.columnSpan: 2
				}
			}

			// slideshow options
			ColumnLayout {

				// Delay between 2 images
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Delay"
						horizontalAlignment: Text.AlignRight
					}
					TextField {
						id: slideShowDelay
						verticalAlignment: Text.BottomLeft
						placeholderText: "Milliseconds"
						onTextChanged: {
							if (root.visible === true) {
								settings.slideShowDelay = parseInt(text);
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Delay in milliseconds between 2 images.";
						}
					}
				}

				// Loop
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Loop"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: slideShowLoop
						onCheckedChanged: {
							if (root.visible === true) {
								settings.slideShowLoop = checked
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"If checked, the slide show will start again when\n" +
									"reaching the last image. Otherwise, it stops.";
						}
					}
				}

				// Use selection
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Use Selection"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: slideShowSelection
						onCheckedChanged: {
							if (root.visible === true) {
								settings.slideShowSelection = checked
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: "If checked, the slide show will use only the current selection."
					}
				}

				// fill the remaining space
				Item {
					Layout.fillHeight: true
					Layout.columnSpan: 2
				}
			}

			// Cache options
			ColumnLayout {

				// use the cache on not
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Use Cache"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: useCache
						onCheckedChanged: {
							if (root.visible === true) {
								mediaProvider.useCache = checked
							}
						}
					}
				}

				// where to store the thumbnails
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Cache Path"
						horizontalAlignment: Text.AlignRight
					}
					TextField {
						id: cachePath
						Layout.fillWidth: true
						enabled: false
						placeholderText: "Folder"
						onTextChanged: {
							if (root.visible === true) {
								mediaProvider.cachePath = text;
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: "Where the cached thumbnails will be stored."
					}
					Button {
						text: "..."
						width: 30
						onClicked: chooseCachePath.open()
						PlatformDialog.FolderDialog {
							id: chooseCachePath
							onAccepted: cachePath.text = folder.toString().replace(/^(file:\/{3})/,"");
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: "Open a dialog to choose where the cached thumbnails will be stored."
					}
				}

				// fill the remaining space
				Item {
					Layout.fillHeight: true
					Layout.columnSpan: 2
				}
			}
		}
	}
}
