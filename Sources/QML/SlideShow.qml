import QtQuick 2.7
import MediaViewer 0.1


//
// Handle the slide shows
//
Item {
	// externally set
	property var settings
	property var stateManager
	property var selection

	// privatee
	property var _medias: []
	property int _current: 0

	// if the viewer exists fullscreen, stop the timer
	Connections {
		target: stateManager
		onStateChanged: if (stateManager.state === "preview") { timer.stop(); }
	}

	// start the slideshow
	function start() {
		// collect the medias
		_medias.length = 0;
		var i = 0,
			media = undefined,
			lastRow = -1,
			index = undefined;
		if (settings.slideShowSelection === true) {
			for (i in selection.selection) {
				index = selection.selection[i];
				media = selection.model.getMedia(index);
				if (media && media.type !== Media.Movie) {
					_medias.push(index);
				}
			}
		} else {
			index = selection.model.getModelIndexByIndex(0);
			while (index.valid !== false) {
				media = selection.model.getMedia(index);
				if (media && media.type !== Media.Movie) {
					_medias.push(index.row);
				}
				if (index.row !== lastRow) {
					index = selection.model.getModelIndexByIndex(index.row + 1);
				} else {
					break;
				}
			}
		}

		// start the slide show if we have something
		if (_medias.length > 0) {
			_current = 0;
			stateManager.state = "fullscren";
			selection.setCurrent(_medias[0]);
			timer.start();
		}
	}

	// the timer used to control the selection
	Timer {
		id: timer
		interval: settings.slideShowDelay
		repeat: true
		triggeredOnStart: false
		onTriggered: {
			// next indeex
			++_current;

			// loop or stop, depending on settings
			if (_current >= _medias.length) {
				if (settings.slideShowLoop === true) {
					_current = 0;
				} else {
					stop();
					stateManager.state = "preview";
				}
			}

			// update the selection
			selection.setCurrent(_medias[_current]);
		}
	}
}
