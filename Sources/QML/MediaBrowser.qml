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
Rectangle {
	id: root

	// externally set
	property var selection
	property var stateManager
	property var settings

	// privates
	property bool _controlDown: false
	property bool _shiftDown: false
	property color _highlight: Material.color(Material.LightBlue, Material.Shade300)
	property color _background: root.color

	// bind settings
	Connections {
		target: settings
		onSortByChanged: selection.model.sortBy = settings.sortBy
		onSortOrderChanged: selection.model.sortOrder = settings.sortOrder
	}

	// handle focus
	function forceFocus() {
		scrollView.forceActiveFocus();
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

			// bind the model
			model: selection ? selection.model : undefined

			// delegate used to draw an item
			Component {
				id: itemDelegate

				Rectangle {
					id: thumbnailBackground
					property string currentPath: path
					width: grid.cellWidth
					height: grid.cellHeight
					color: _background

					// check selection change to update the background
					Connections {
						target: selection
						onSelectionChanged: thumbnailBackground.color = selection.isSelected(index) ? _highlight : _background
					}

					// the media preview
					Loader {
						id: image
						asynchronous: true

						// size and anchoring
						height: parent.height - 20 - (label.active ? label.height + 10 : 0)
						width: parent.width - 20
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.top: parent.top
						anchors.topMargin: 10

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
					Loader {
						id: label
						active: settings.showLabel

						// position in the thumbnail
						width: parent.width - 20
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.bottom: parent.bottom
						anchors.bottomMargin: 10

						// the label
						sourceComponent: Label {
							horizontalAlignment: Text.AlignHCenter
							elide: Text.ElideMiddle
							text: name
						}
					}
				}
			}

			// notify the selection manager that the index changed
			onCurrentIndexChanged: {
				if (stateManager.state === "preview") {
					if (_controlDown === true) {
						selection.toggleSelection(grid.currentIndex);
					} else if (_shiftDown === true) {
						selection.extendSelection(grid.currentIndex);
					} else {
						selection.setCurrent(grid.currentIndex);
					}
				}
			}

			// update the view's current item when the selection manager's current index changed
			Connections {
				target: selection
				onCurrentChanged: {
					if (stateManager.state === "fullscreen") {
						grid.currentIndex = selection.current.row;
					}
				}
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
					var index = grid.currentIndex;
					grid.currentIndex = grid.indexAt(
						mouse.x + grid.contentX,
						mouse.y + grid.contentY
					);

					// if the selection is the same, force notification since we might want to
					// toggle the active item's selection
					if (index === grid.currentIndex) {
						grid.currentIndexChanged(index);
					}
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
				case Qt.Key_Control:
					event.accepted = true;
					_controlDown = true;
					break;
				case Qt.Key_Shift:
					event.accepted = true;
					_shiftDown = true;
					break;
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
		Keys.onReleased: {
			switch (event.key) {
				case Qt.Key_Control:
					event.accepted = true;
					_controlDown = false;
					break;
				case Qt.Key_Shift:
					event.accepted = true;
					_shiftDown = false;
					break;
			}
		}
	}
}
