import QtQuick 2.5


//
// Animated image view
//
AnimatedImage {
	id: image

	// externally set
	property var selection
	property var stateManager

	// resize to only fit when the image is greater than the view size
	function resize() {
		if (sourceSize.width > width || sourceSize.height > height) {
			fillMode = Image.PreserveAspectFit;
		} else {
			fillMode = Image.Pad;
		}
	}

	// configure the image for best quality
	asynchronous: true
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true

	// resize when needed
	onStatusChanged: if (status === Image.Ready) { resize(); }
	onWidthChanged: resize();
	onHeightChanged: resize();
}
