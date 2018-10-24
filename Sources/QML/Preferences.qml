import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.3
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

	TabView {
		id: bar
		anchors.fill: parent
		clip: true

		Tab {
			title: "General"
			anchors.margins: 10
			active: true

			ScrollView {

				onVisibleChanged: {
					if (visible === false) {
						return;
					}

					restoreLastVisitedFolder.checked	= settings.restoreLastVisitedFolder;
					deletePermanently.checked			= fileSystem.canTrash === true ? settings.deletePermanently : true;
				}

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

		Tab {
			title: "Interface"
			anchors.margins: 10
			active: true

			ScrollView {

				onVisibleChanged: {
					if (visible === false) {
						return;
					}

					sortBy.currentIndex					= settings.sortBy;
					sortOrder.currentIndex				= settings.sortOrder;
					thumbnailSize.value					= settings.thumbnailSize;
					showLabel.checked					= settings.showLabel;
				}

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

		Tab {
			title: "Slide Show"
			anchors.margins: 10
			active: true

			ScrollView {

				onVisibleChanged: {
					if (visible === false) {
						return;
					}

					slideShowDelay.text					= settings.slideShowDelay;
					slideShowLoop.checked				= settings.slideShowLoop;
					slideShowSelection.checked			= settings.slideShowSelection;
				}

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

		Tab {
			id: cacheBar
			title: "Thumbnail Cache"
			anchors.margins: 10
			active: true

			ScrollView {

				onVisibleChanged: {
					if (visible === false) {
						return;
					}

					useCache.checked	= mediaProvider.useCache;
					cachePath.text		= mediaProvider.cachePath;
				}

				ColumnLayout {
					width: cacheBar.width

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
						}
						Button {
							text: "..."
							width: 30
							onClicked: chooseCachePath.open()
							PlatformDialog.FolderDialog {
								id: chooseCachePath
								onAccepted: {
									console.log(folder.toString().replace(/^(file:\/{3})/,""));
									cachePath.text = folder.toString().replace(/^(file:\/{3})/,"");
								}
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
}

