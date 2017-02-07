import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2


//
// The media browser. We use a grid view which is a flickable view, so We
// need to add a scroll view to make the scroll bar visible on Desktop
//
ScrollView {
	id: scrollView

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
						source: "image://Thumbnail/" + path
						sourceSize.width: root.cellWidth - 20
						sourceSize.height: root.cellHeight - 20 - label.height - 20
						anchors.horizontalCenter: parent.horizontalCenter
						fillMode: sourceSize.width > width || sourceSize.height > height ? Image.PreserveAspectFit : Image.Pad
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
