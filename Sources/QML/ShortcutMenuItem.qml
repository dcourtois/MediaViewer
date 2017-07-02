import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


MenuItem {
	id: root

	// the API
	property alias sequence: shortcut.sequence

	// replace the content to be able to display the shortcut sequence
	contentItem: RowLayout {
		Label { text: root.text }
		Item { Layout.fillWidth: true; Layout.minimumWidth: 20 }
		Label { text: shortcut.sequence }
	}

	// shortcut
	Shortcut {
		id: shortcut
		enabled: parent.enabled
		context: Qt.ApplicationShortcut
		onActivated: root.triggered()
	}
}
