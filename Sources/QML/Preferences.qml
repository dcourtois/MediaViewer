import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import MediaViewer 0.1


Dialog {
	id: root
	title: "Preferences"
	standardButtons: Dialog.Ok
	width: 600

	// externally set
	property var mediaBrowser
	property var settings

	// private properties
	property int _labelWidth: 250

	// setup when the dialog is shown (to avoid binding loops)
	onVisibleChanged: {
		if (visible === true) {
			playAnimatedImages.currentIndex		= settings.playAnimatedImages;
			playMovies.currentIndex				= settings.playMovies;
			sortBy.currentIndex					= settings.sortBy;
			sortOrder.currentIndex				= settings.sortOrder;
			thumbnailSize.value					= settings.thumbnailSize;
			restoreLastVisitedFolder.checked	= settings.restoreLastVisitedFolder;
			deletePermanently.checked			= fileSystem.canTrash === true ? settings.deletePermanently : true;
			showLabel.checked					= settings.showLabel;
			slideShowDelay.text					= settings.slideShowDelay;
			slideShowLoop.checked				= settings.slideShowLoop;
			slideShowSelection.checked			= settings.slideShowSelection;
		} else {
			// restore the previous focus item
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
				width: column.width / 3
				text: "General"
			}

			TabButton {
				width: column.width / 3
				text: "Interface"
			}

			TabButton {
				width: column.width / 3
				text: "Slide Show"
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
				// Play mode of animated images in preview
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Auto Play Animated Images"
						horizontalAlignment: Text.AlignRight
					}
					ComboBox {
						id: playAnimatedImages
						Layout.fillWidth: true
						model: [
							"On",
							"Mouse Hover",
							"Off"
						]
						onCurrentIndexChanged: {
							if (root.visible === true) {
								settings.playAnimatedImages = currentIndex
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Select auto play mode for animated images in the\n" +
									"media browser:\n" +
									"  - On : always play\n" +
									"  - Mouse Hover : only play when the mouse is over the media\n" +
									"  - Off : never play\n";
						}
					}
				}

				// Play mode of movies in preview
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Auto Play Movies"
						horizontalAlignment: Text.AlignRight
					}
					ComboBox {
						id: playMovies
						Layout.fillWidth: true
						model: [
							"On",
							"Mouse Hover",
							"Off"
						]
						onCurrentIndexChanged: {
							if (root.visible === true) {
								settings.playMovies = currentIndex
							}
						}
						ToolTip.delay: 1000
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Select auto play mode for movies in the media browser:\n" +
									"  - On : always play\n" +
									"  - Mouse Hover : only play when the mouse is over the media\n" +
									"  - Off : never play\n";
						}
					}
				}

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

				// Delete permanently
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
						ToolTip.text: {
							return	"If checked, the slide show will use only the current selection.";
						}
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

