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
	function hasPrevious(index) {
		index = index ? index : current;
		return model.getPreviousModelIndex(index) !== index;
	}

	// check if we have a next media
	function hasNext(index) {
		index = index ? index : current;
		return model.getNextModelIndex(index) !== index;
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

	// check if we have a selection
	function hasSelection() {
		return selection.length !== 0;
	}

	// select everything
	function selectAll() {
		selection.length = 0;
		var index = { valid: false },
			newIndex = convertIndex(0);
		while (newIndex.valid === true && index !== newIndex) {
			selection.push(newIndex);
			index = newIndex;
			newIndex = model.getNextModelIndex(index);
		}
		current = selection.length !== 0 ? selection[0] : { valid: false };
		selectionChanged();
	}

	// inverse selection
	function selectInverse() {
		var index = { valid: false },
			newIndex = convertIndex(0),
			newSelection = [];
		while (newIndex.valid === true && index !== newIndex) {
			if (indexOf(newIndex) === -1) {
				newSelection.push(newIndex);
			}
			index = newIndex;
			newIndex = model.getNextModelIndex(index);
		}
		current = newSelection.length !== 0 ? newSelection[0] : { valid: false };
		selection = newSelection;
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

	// return a list of selected paths
	function getSelectedPaths() {
		var paths = [];
		for (var i = 0; i < selection.length; ++i) {
			paths.push(model.getMedia(selection[i]).path);
		}
		return paths;
	}

	// get the first selected model index
	function getFirstSelected() {
		return selection.length > 0 ? selection[0] : { valid: false };
	}

	// get the last selected model index
	function getLastSelected() {
		return selection.length > 0 ? selection[selection.length - 1] : { valid: false };
	}

	// update the current media
	onCurrentChanged: currentMedia = current.valid ? model.getMedia(current) : undefined
}
