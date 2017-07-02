import QtQuick 2.5
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.2
import QtMultimedia 5.8
import Qt.labs.settings 1.0
import MediaViewer 0.1


//
// The media browser.
//
Item {
	id: root

	// externally set
	property var selection
	property var stateManager
	property var settings

	// configure looks
	property color highlightColor: Material.color(Material.LightBlue, Material.Shade300)

	// bind settings
	Connections {
		target: settings
		onSortByChanged: selection.model.sortBy = settings.sortBy
		onSortOrderChanged: selection.model.sortOrder = settings.sortOrder
	}

	// use a scroll view to show a scroll bar (GridView is a flickable, so
	// it doesn't show any scroll bar)
	Controls.ScrollView {
		id: scrollView
		anchors.fill: parent

		// the grid view
		GridView {
			id: grid

			// size of the cells
			cellWidth: settings.thumbnailSize * 350 + 50
			cellHeight: settings.thumbnailSize * 350 + 50

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
					width: grid.cellWidth
					height: grid.cellHeight
					Item {
						width: image.width
						height: image.height + label.height
						anchors.centerIn: parent

						// the media preview
						Loader {
							id: image
							asynchronous: true

							// size and anchoring
							width: grid.cellWidth - 20
							height: grid.cellHeight - 20 - label.height - 20
							anchors.horizontalCenter: parent.horizontalCenter

							// make path accessible to components
							property string sourcePath: path

							// load the correct component
							source: {
								switch (type) {
									case Media.Movie:			return "qrc:///Previews/Movie.qml";
									case Media.AnimatedImage:	return "qrc:///Previews/AnimatedImage.qml";
									case Media.Image:			return "qrc:///Previews/Image.qml";
								}
							}
						}

						// the label
						Label {
							id: label
							width: grid.cellWidth - 20
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
					x: grid.currentItem ? grid.currentItem.x : 0
					y: grid.currentItem ? grid.currentItem.y : 0
					width: grid.cellWidth
					height: grid.cellHeight
					color: highlightColor
				}
			}

			// notify the selection manager that the index changed
			onCurrentItemChanged: selection.selectByPath(currentItem ? currentItem.currentPath : "")

			// update the view's current item when the selection manager's current index changed
			Binding {
				target: grid
				property: "currentIndex"
				value: selection.currentMediaIndex
				when: selection
			}

			// Mouse handling
			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton

				// update selection
				onClicked: {
					// grab the focus (the folder tree view can have it, and after
					// a click on the media, we usually want to browse them with the keyboard)
					// note: don't know why I can't use parent (must use scrollView id) and also
					// don't know why I can't set the focus on grid ...
					scrollView.focus = true;

					// select the item under the mouse
					grid.currentIndex = grid.indexAt(
						mouse.x + grid.contentX,
						mouse.y + grid.contentY
					);
				}

				// toggle fullscreen
				onDoubleClicked: {
					if (selection.currentMedia) {
						stateManager.state = "fullscreen";
					}
				}
			}
		}

		// Keyboard handling
		Keys.onPressed: {
			switch (event.key) {
				case Qt.Key_Down:
					event.accepted = true;
					grid.moveCurrentIndexDown();
					break;
				case Qt.Key_Up:
					event.accepted = true;
					grid.moveCurrentIndexUp();
					break;
				case Qt.Key_Left:
					event.accepted = true;
					grid.moveCurrentIndexLeft();
					break;
				case Qt.Key_Right:
					event.accepted = true;
					grid.moveCurrentIndexRight();
					break;
				case Qt.Key_Enter:
				case Qt.Key_Return:
					stateManager.state = "fullscreen";
					break;
			}
		}
	}
}
