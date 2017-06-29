import QtQuick 2.5


//
// Simple static image. It's loaded synchronously, so use in an asynchronously
// loaded componenet :)
//
Image {
	source: "file:///" + sourcePath
	fillMode: sourceSize.width >= width || sourceSize.height >= height ? Image.PreserveAspectFit : Image.Pad
	asynchronous: false
	antialiasing: true
	autoTransform: true
	smooth: true
	mipmap: true
}

