import QtQuick 2.12
import QtQuick.Controls 2.12


//!
//! Helper for ToolButton
//!
ToolButton {
	id: root

	// automatically size the icon
	icon.height: root.height / 2
	icon.width: icon.height

	// source points to the icon's source
	property alias source: root.icon.source

}
