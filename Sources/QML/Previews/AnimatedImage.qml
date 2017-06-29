import QtQuick 2.5


//
// Animated image. It's loaded synchronously, so use in an asynchronously
// loaded componenet :)
//
AnimatedImage {
	source: "file:///" + sourcePath
	fillMode: sourceSize.width >= width || sourceSize.height >= height ? Image.PreserveAspectFit : Image.Pad
	asynchronous: false
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true

	// privates
	property bool _mouseHover: false

	// mouse hover detection
	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		onEntered: parent._mouseHover = true
		onExited: parent._mouseHover = false
	}
}

