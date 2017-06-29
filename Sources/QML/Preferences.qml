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
	property var settings

	// private properties
	property int _labelWidth: 200

	// init (to avoid binding loops)
	onVisibleChanged: {
		if (visible === true) {
			playAnimatedImages.currentIndex		= settings.playAnimatedImages;
			playMovies.currentIndex				= settings.playMovies;
			sortBy.currentIndex					= settings.sortBy;
			sortOrder.currentIndex				= settings.sortOrder;
			thumbnailSize.value					= settings.thumbnailSize;
		}
	}

	// main layout
	ColumnLayout {
		anchors.fill: parent

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

		// fill the remaining space
		Item {
			Layout.fillHeight: true
			Layout.columnSpan: 2
		}
	}
}

