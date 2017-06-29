import QtQuick 2.5
import QtQml.Models 2.2
import MediaViewer 0.1


//
// Media selection model
//
ItemSelectionModel {

	// the current media
	property var currentMedia
	property string currentMediaPath: "qrc:///images/empty"
	property int currentMediaType: Media.NotSupported
	property int currentMediaIndex: -1

	// check if we have a previous media
	function hasPrevious() {
		return model ? model.getPreviousModelIndex(currentIndex).valid : false;
	}

	// check if we have a next media
	function hasNext() {
		return model ? model.getNextModelIndex(currentIndex).valid : false;
	}

	// set the current media by path
	function selectByPath(path) {
		setCurrent(model.getModelIndexByPath(path));
	}

	// set the current media by index
	function selectByIndex(index) {
		setCurrent(model.getModelIndexByIndex(index));
	}

	// select the previous media
	function selectPrevious() {
		setCurrent(model.getPreviousModelIndex(currentIndex));
	}

	// select the next media
	function selectNext() {
		setCurrent(model.getNextModelIndex(currentIndex));
	}

	// select the last media
	function selectLast() {
		setCurrent(model.getLastModelIndex());
	}

	// helper
	function setCurrent(index) {
		if (model) {
			setCurrentIndex(index, ItemSelectionModel.Current);
		}
	}

	// detect changes
	onCurrentChanged: {
		if (model) {
			if (current.valid) {
				currentMedia = model.getMedia(current);
				currentMediaType = currentMedia.type;
				currentMediaPath = "file:///" + currentMedia.path;
				currentMediaIndex = model.getIndex(current);
			} else {
				currentMedia = undefined;
				currentMediaType = Media.NotSupported
				currentMediaPath = "qrc:///images/empty";
				currentMediaIndex = -1;;
			}
		}
	}
}
