import QtQuick 2.5
import MediaViewer 0.1


//
// Media selection model.
//
Item {
	// externally set
	property var model

	// selection
	property var current: { valid: false }
	property var currentMedia: undefined
	property var selection: []

	// check if we have a previous media
	function hasPrevious() {
		return model.getPreviousModelIndex(current) !== current;
	}

	// check if we have a next media
	function hasNext() {
		return model.getNextModelIndex(current) !== current;
	}

	// set the current media by path
	function selectByPath(path) {
		setCurrent(model.getModelIndexByPath(path));
	}

	// select the previous media
	function selectPrevious() {
		setCurrent(model.getPreviousModelIndex(current));
	}

	// select the next media
	function selectNext() {
		setCurrent(model.getNextModelIndex(current));
	}

	// check if the given index is selected
	function isSelected(index) {
		return indexOf(convertIndex(index)) !== -1;
	}

	// add to the selection
	function select(index) {
		current = convertIndex(index);
		selection.push(current);
		selectionChanged(selection);
	}

	// toggle selection
	function toggleSelection(index) {
		if (isSelected(index) === true) {
			unselect(index);
		} else {
			select(index);
		}
	}

	// remove from the selection
	function unselect(index) {
		// compute the index in the current selection
		index = convertIndex(index);
		var i = indexOf(index);
		if (i !== -1) {
			// update the current
			if (i > 0) {
				current = selection[i - 1];
			} else if (i < selection.length - 1) {
				current = selection[i + 1];
			} else {
				current = { valid: false };
			}

			// remove from the selection
			selection.splice(i, 1);
			selectionChanged(selection);
		}
	}

	// overwrite the selection
	function setCurrent(index) {
		index = convertIndex(index);
		selection = [ index ];
		current = index;
	}

	// extend the selection
	function extendSelection(index) {
		// reset the selection
		selection.length = 0;

		// get the start and end indices
		index = convertIndex(index);
		var start = current.valid ? current.row : 0,
			end = index.row;
		if (start > end) {
			end = start;
			start = index.row;
		}

		// add items
		for (var i = start; i <= end; ++i) {
			selection.push(convertIndex(i));
		}

		// update
		selectionChanged(selection);
	}

	// clear the selection
	function clear() {
		selection = [];
		current = { valid: false };
	}

	// convert a numerical index (row) into a model index
	function convertIndex(index) {
		return typeof index === "number" ? model.getModelIndexByIndex(index) : index;
	}

	// get the index of an index in the selection
	function indexOf(index) {
		for (var i = 0; i < selection.length; ++i) {
			if (index.row === selection[i].row) {
				return i;
			}
		}
		return -1;
	}

	// update the current media
	onCurrentChanged: currentMedia = current.valid ? model.getMedia(current) : undefined
}
