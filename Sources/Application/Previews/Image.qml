import QtQuick 2.5


//
// Simple static image.
//
Image {
	source: "image://MediaPreview/" + sourcePath + "?" + parent.width + "&" + parent.height
	fillMode: Image.PreserveAspectFit
	asynchronous: true
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true
}
