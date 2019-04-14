import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0 as PlatformDialog
import MediaViewer 0.1


Dialog {
	id: root
	modal: true
	title: "Preferences"
	standardButtons: Dialog.Ok
	width: 600
	height: 400

	// externally set
	property var mediaBrowser

	// private properties
	property int _tooltipDelay: 750
	property int _labelWidth: Math.max(root.width / 3, 200)

	ColumnLayout {
		id: column
		anchors.fill: parent

		// tab bar header
		TabBar {
			id: bar
			width: parent.width

			TabButton {
				width: column.width / bar.contentChildren.length
				text: "General"
			}

			TabButton {
				width: column.width / bar.contentChildren.length
				text: "Interface"
			}

			TabButton {
				width: column.width / bar.contentChildren.length
				text: "Slide Show"
			}

			TabButton {
				width: column.width / bar.contentChildren.length
				text: "Cache"
			}
		}

		// tabs content
		StackLayout {
			width: parent.width
			currentIndex: bar.currentIndex

			// general options
			ColumnLayout {
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

				// Remember last visited folder
				RowLayout {
					spacing: 10
					Label {
						Layout.minimumWidth: _labelWidth
						text: "Remember Last Visited Folder"
						horizontalAlignment: Text.AlignRight
					}
					CheckBox {
						id: restoreLastVisitedFolder
						checked: settings.get("General.RestoreLastVisitedFolder", true)
						onCheckedChanged: settings.set("General.RestoreLastVisitedFolder", checked)
						ToolTip.delay: _tooltipDelay
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
						checked: fileSystem.canTrash ? settings.get("FileSystem.DeletePermanently") : true
						onCheckedChanged: settings.set("FileSystem.DeletePermanently", checked)
						ToolTip.delay: _tooltipDelay
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
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

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
						currentIndex: settings.get("Media.SortBy")
						onCurrentIndexChanged: settings.set("Media.SortBy", currentIndex)
						ToolTip.delay: _tooltipDelay
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
						currentIndex: settings.get("Media.SortOrder")
						onCurrentIndexChanged: settings.set("Media.SortOrder", currentIndex)
						ToolTip.delay: _tooltipDelay
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
						from: 10
						to: 300
						value: settings.get("Media.ThumbnailSize")
						onValueChanged: settings.set("Media.ThumbnailSize", Math.round(value))
						ToolTip.delay: _tooltipDelay
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
						checked: settings.get("Media.ShowLabel", true)
						onCheckedChanged: settings.set("Media.ShowLabel", checked)
						ToolTip.delay: _tooltipDelay
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
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

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
						text: settings.get("Slideshow.Delay")
						onTextChanged: settings.set("Slideshow.Delay", parseInt(text))
						ToolTip.delay: _tooltipDelay
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
						checked: settings.get("Slideshow.Loop")
						onCheckedChanged: settings.set("Slideshow.Loop", slideShowLoop.checked)
						ToolTip.delay: _tooltipDelay
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
						checked: settings.get("Slideshow.Selection", true)
						onCheckedChanged: settings.set("Slideshow.Selection", checked)
						ToolTip.delay: _tooltipDelay
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
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

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
						checked: settings.get("MediaPreviewProvider.UseCache", true)
						onCheckedChanged: mediaProvider.useCache = checked
						ToolTip.delay: _tooltipDelay
						ToolTip.visible: hovered
						ToolTip.text: "When checked, thumbnails will be stored in a cache."
					}
				}

				// where to store the thumbnails
				RowLayout {
					Layout.fillWidth: true
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
						text: settings.get("MediaPreviewProvider.CachePath")
						onTextChanged: mediaProvider.cachePath = text
						ToolTip.delay: _tooltipDelay
						ToolTip.visible: hovered
						ToolTip.text: "Where the cached thumbnails are stored."
					}
					Button {
						text: "..."
						width: 30
						onClicked: chooseCachePath.open()
						PlatformDialog.FolderDialog {
							id: chooseCachePath
							onAccepted: cachePath.text = folder.toString().replace(/^(file:\/{3})/,"");
						}
						ToolTip.delay: _tooltipDelay
						ToolTip.visible: hovered
						ToolTip.text: {
							return	"Open a dialog to choose where the cached thumbnails will be stored.\n" +
									"Note that a 'Cache' subdirectory will be added to the chosen dir:\n" +
									"if you choose 'D:/Documents', then the actual folder will be 'D:/Document/Cache'";
						}
					}
				}

				Button {
					Layout.fillWidth: true
					text: "Clear Cache"
					ToolTip.delay: _tooltipDelay
					ToolTip.visible: hovered
					ToolTip.text: "Empty the whole cache folder."
					onClicked: mediaProvider.clearCache()
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
