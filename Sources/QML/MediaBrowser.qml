import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import MediaViewer 0.1


//
// The media browser. We use a grid view which is a flickable view, so We
// need to add a scroll view to make the scroll bar visible on Desktop
//
Item {
	// externally set
	property alias selection: scrollView.selection
	property alias stateManager: scrollView.stateManager

	ColumnLayout {
		anchors.fill: parent

		//
		// The sorting controls
		//
		RowLayout {
			Layout.fillWidth: true
			Layout.margins: 10
			spacing: 10

			Text {
				text: "Sort By:"
			}
			ComboBox {
				Layout.fillWidth: true
				currentIndex: selection.model.sortBy
				model: ListModel {
					id: sortByModel
					ListElement { text: "Name"; value: MediaModel.Name }
					ListElement { text: "Size"; value: MediaModel.Size }
					ListElement { text: "Date"; value: MediaModel.Date }
					ListElement { text: "Type"; value: MediaModel.Type }
					ListElement { text: "None"; value: MediaModel.None }
				}
				onCurrentIndexChanged: selection.model.sortBy = sortByModel.get(currentIndex).value
			}
			Text {
				text: "Sort Order:"
			}
			ComboBox {
				Layout.fillWidth: true
				currentIndex: selection.model.sortOrder
				model: ListModel {
					id: sortOrderModel
					ListElement { text: "Ascending"; value: MediaModel.Ascending }
					ListElement { text: "Descending"; value: MediaModel.Descending }
				}
				onCurrentIndexChanged: selection.model.sortOrder = sortOrderModel.get(currentIndex).value
			}
		}

		//
		// The media scroll view
		//
		ScrollView {
			id: scrollView
			Layout.fillHeight: true
			Layout.fillWidth: true

			// externally set
			property var selection
			property var stateManager

			// the grid view
			GridView {
				id: root

				// size of the cells
				cellWidth: 220
				cellHeight: 230

				// disable animation of the selection
				highlightFollowsCurrentItem: false

				// delegates
				delegate: itemDelegate
				highlight: highlightDelegate

				// bind the model
				model: selection ? selection.model : undefined

				// delegate used to draw an item
				Component {
					id: itemDelegate
					Item {
						property string currentPath: path
						width: root.cellWidth
						height: root.cellHeight
						Item {
							width: image.width
							height: image.height + label.height
							anchors.centerIn: parent
							Image {
								id: image
								source: type === Media.Movie ? "image://Thumbnail/0/" + path : "file:///" + path
								sourceSize.width: root.cellWidth - 20
								sourceSize.height: root.cellHeight - 20 - label.height - 20
								width: sourceSize.width
								height: sourceSize.height
								anchors.horizontalCenter: parent.horizontalCenter
								fillMode: sourceSize.width >= width || sourceSize.height >= height ? Image.PreserveAspectFit : Image.Pad
								asynchronous: true
								antialiasing: true
								autoTransform: true
								smooth: true
								mipmap: true
							}
							Text {
								id: label
								width: root.cellWidth - 20
								horizontalAlignment: Text.AlignHCenter
								elide: Text.ElideRight
								text: name
								anchors.top: image.bottom
								anchors.topMargin: 10
								anchors.horizontalCenter: parent.horizontalCenter
							}
						}
					}
				}

				// delegate used to draw the selected highlight
				Component {
					id: highlightDelegate
					Rectangle {
						x: root.currentItem ? root.currentItem.x : 0
						y: root.currentItem ? root.currentItem.y : 0
						width: root.cellWidth
						height: root.cellHeight
						color: "lightBlue"
					}
				}

				//
				// synchronise the grid view's selection to our selection model
				//
				onCurrentItemChanged: {
					if (currentItem) {
						selection.selectByPath(currentItem.currentPath);
					} else {
						selection.selectByPath("");
					}
				}
				Binding {
					target: root
					property: "currentIndex"
					value: selection.currentMediaIndex
					when: selection
				}

				// Mouse handling
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton
					onClicked: {
						// acquire the focus (the folder browser might have it, and we want
						// to be able to navigate with the keyboard)
						scrollView.focus = true;

						// update the current index
						root.currentIndex = root.indexAt(
							mouse.x + root.contentX,
							mouse.y + root.contentY
						);
					}
					onDoubleClicked: {
						if (selection.currentMedia) {
							stateManager.state = "fullscreen";
						}
					}
				}
			}

			// keyboard handling
			Keys.onPressed: {
				switch (event.key) {
					case Qt.Key_Down:
						event.accepted = true;
						root.moveCurrentIndexDown();
						break;
					case Qt.Key_Up:
						event.accepted = true;
						root.moveCurrentIndexUp();
						break;
					case Qt.Key_Left:
						event.accepted = true;
						root.moveCurrentIndexLeft();
						break;
					case Qt.Key_Right:
						event.accepted = true;
						root.moveCurrentIndexRight();
						break;
					case Qt.Key_Enter:
					case Qt.Key_Return:
						stateManager.state = "fullscreen";
						break;
				}
			}
		}
	}
}
