import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


MenuItem {
	id: root

	// the API
	property alias sequence: shortcut.sequence
	property alias sequences: shortcut.sequences
	property int space: 10

	// replace the content to be able to display the shortcut sequence
	contentItem: RowLayout {
		Label { text: root.text }
		Item { Layout.fillWidth: true; Layout.minimumWidth: root.space }
		Label { text: shortcut.nativeText; enabled: false }
	}

	// shortcut
	Shortcut {
		id: shortcut
		enabled: parent.enabled
		context: Qt.ApplicationShortcut
		onActivated: root.triggered()
	}
}
