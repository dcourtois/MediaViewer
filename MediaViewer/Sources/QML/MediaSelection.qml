import QtQuick 2.5
import QtQml.Models 2.2
import MediaViewerLib 0.1


//
// Media selection model
//
ItemSelectionModel {

	// the current media
	property var currentMedia: null
	property var currentMediaPath: "qrc:///images/empty"
	property var currentMediaType: Media.NotSupported
	property var currentMediaIndex: -1

	// set the current media by path
	function selectByPath(path) {
		if (model) {
			var index = model.getModelIndexByPath(path);
			setCurrentIndex(index, ItemSelectionModel.Current);
		}
	}

	// select the previous media
	function selectPrevious() {
		if (model) {
			var index = model.getPreviousModelIndex(currentIndex);
			if (index.valid) {
				setCurrentIndex(index, ItemSelectionModel.Current);
			}
		}
	}

	// select the next media
	function selectNext() {
		if (model) {
			var index = model.getNextModelIndex(currentIndex);
			if (index.valid) {
				setCurrentIndex(index, ItemSelectionModel.Current);
			}
		}
	}

	// detect changes
	onCurrentChanged: {
		if (model) {
			if (current.valid) {
				currentMedia = model.getMedia(current);
				currentMediaPath = "file:///" + currentMedia.path;
				currentMediaIndex = model.getIndex(current);
				currentMediaType = currentMedia.type;
			} else {
				currentMedia = null;
				currentMediaPath = "qrc:///images/empty";
				currentMediaIndex = -1;
				currentMediaType = Media.NotSupported;
			}
		}
	}
}
