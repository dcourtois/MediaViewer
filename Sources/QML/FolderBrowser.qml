import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQml.Models 2.2
import Qt.labs.settings 1.0



//
// A tree view used to browse the folders' contents
//
TreeView {
	id: root

	// The currently selected path
	property string currentFolderPath: ""

	//
	// set the currently selected item from its path
	//
	function setCurrentFolderPath(path) {
		// get the index from the path
		var index = model.getIndexByPath(path);

		// select the index, and expand the hierarchy
		if (index.valid) {
			// select the item
			folderSelectionModel.setCurrentIndex(index, ItemSelectionModel.Current);

			// expand the items
			while (index.valid) {
				root.expand(index);
				index = index.parent;
			}
		}
	}

	//
	// default settings
	//
	Settings {
		id: settings
		property string currentFolderPath: ""
	}

	//
	// Initialization
	//
	Component.onCompleted: {
		setCurrentFolderPath(settings.currentFolderPath);
	}

	//
	// Bindings
	//
	onCurrentFolderPathChanged: settings.currentFolderPath = currentFolderPath

	//-------------------------------------------------------------------------
	// Privates
	//

	// Colors
	property color selectedColor: Qt.rgba(0.68, 0.85, 0.91, 1)
	property color evenColor: Qt.rgba(1, 1, 1, 1)
	property color oddColor: Qt.rgba(0.96, 0.96, 0.96, 1)

	// Don't need the headers
	headerVisible: false

	// The selection model
	selection: ItemSelectionModel {
		id: folderSelectionModel
		model: root.model
		onCurrentChanged: currentFolderPath = (current.valid ? model.data(current, 256) : "")
	}

	// Draw the row's background
	rowDelegate: Rectangle {
		height: 20
		color: styleData.selected ? selectedColor : (styleData.alternate ? evenColor : oddColor)
	}

	// Display the content
	TableViewColumn {
		role: "folder"

		// todo: investigate why we receive 2 calls to the delegate,
		// one with styleData.value being an empty string, and the next
		// one being the correct value.
		delegate: Item {

			// folder icon
			Image {
				id: delegateIcon
				anchors.verticalCenter: parent.verticalCenter
				asynchronous: true
				source: styleData.value ? "image://FolderIcon/" + styleData.value.path : "qrc:///images/empty"
			}

			// folder name
			Text {
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: delegateIcon.right
				anchors.leftMargin: 5
				anchors.right: delegateMediaCount.visible ? delegateMediaCount.left : parent.right
				anchors.rightMargin: 5
				elide: Text.ElideRight
				font.pixelSize: sourceSans.size
				font.family: sourceSans.name
				text: styleData.value ? styleData.value.name : ""
			}

			// media count
			Rectangle {
				id: delegateMediaCount

				visible: styleData.value ? styleData.value.mediaCount !== 0 : false

				anchors.right: parent.right
				anchors.rightMargin: 5
				anchors.top: parent.top
				anchors.topMargin: 2
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 2

				width: delegateMediaCountText.contentWidth + 10

				radius: 10
				color: styleData.selected ? evenColor : selectedColor;

				Text {
					id: delegateMediaCountText

					anchors.centerIn: parent

					font.pixelSize: 12
					font.family: sourceSans.name
					text: styleData.value ? styleData.value.mediaCount : ""
				}
			}
		}
	}
}
