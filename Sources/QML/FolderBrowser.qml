import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Controls 1.4 as Controls
import QtQuick.Layouts 1.2
import QtQml.Models 2.2
import Qt.labs.settings 1.0


//
// A tree view used to browse the folders' contents
//
Controls.TreeView {
	id: root

	// The currently selected path
	property string currentFolderPath: ""

	// set the currently selected item from its path
	function setCurrentFolderPath(path) {
		// get the index from the path
		var index = model.getIndexByPath(path);

		// select the index, and expand the hierarchy
		if (index.valid) {
			// select the item
			folderSelectionModel.setCurrentIndex(index, ItemSelectionModel.Current);

			// expand the items up to the root
			while (index.valid) {
				root.expand(index);
				index = index.parent;
			}
		}
	}

	// default settings
	Settings {
		id: settings
		property string currentFolderPath: ""
	}

	// Initialization
	Component.onCompleted: {
		setCurrentFolderPath(settings.currentFolderPath);
	}

	// Bindings
	onCurrentFolderPathChanged: settings.currentFolderPath = currentFolderPath

	//-------------------------------------------------------------------------
	// Privates
	//

	// Colors
	property color selectedColor: Material.color(Material.LightBlue, Material.Shade300)
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
		height: 24
		color: styleData.selected ? selectedColor : (styleData.alternate ? evenColor : oddColor)
	}

	// disable the item delegate
	// note: we're using a TableViewColumn to access the folders, and custom draw each
	// rows. When doing this, the itemDelegate of TreeView is no longer used (try replacing
	// null by Text { text: "foo" })
	// But the TreeView style still seems to be trying to instanciate it at least once.
	// And since the default implementation is a Text, and since we used the "folder"
	// role, the style will try to assign a MediaViewer::Folder to a text property.
	// So this here ensurs that the itemDelegate will never be used.
	itemDelegate: null

	// Display the content
	Controls.TableViewColumn {
		role: "folder"

		// draw a row delegate
		delegate: Item {

			// folder icon
			Image {
				id: delegateIcon
				anchors.verticalCenter: parent.verticalCenter
				asynchronous: true
				source: styleData.value ? "image://FolderIcon/" + styleData.value.path : "qrc:///images/empty"
			}

			// folder name
			Label {
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: delegateIcon.right
				anchors.leftMargin: 5
				anchors.right: delegateMediaCount.visible ? delegateMediaCount.left : parent.right
				anchors.rightMargin: 5
				elide: Text.ElideRight
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

				Label {
					id: delegateMediaCountText
					anchors.centerIn: parent
					text: styleData.value ? styleData.value.mediaCount : ""
					font.pixelSize: 12
				}
			}
		}
	}
}
