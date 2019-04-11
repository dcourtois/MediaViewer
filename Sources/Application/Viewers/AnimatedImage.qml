import QtQuick 2.5


//
// Animated image view
//
AnimatedImage {
	id: image

	// resize to only fit when the image is greater than the view size
	fillMode: (sourceSize.width > width || sourceSize.height > height) ? Image.PreserveAspectFit : Image.Pad

	// configure the image for best quality
	asynchronous: true
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true
}
