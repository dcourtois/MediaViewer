import QtQuick 2.7
import MediaViewer 0.1


//
// Handle the slide shows
//
Item {
	// externally set
	property var stateManager
	property var selection
	property var _mediaViewer

	// private
	property var _backupCurrent: { valid: false }
	property var _backupSelection: []
	property var _medias: []
	property int _current: 0

	// if the viewer exists fullscreen, stop the timer
	Connections {
		target: stateManager
		enabled: timer.running === true
		onStateChanged: {
			if (stateManager.state === "preview") {
				timer.stop();

				// restore selection
				selection.setCurrent(_backupCurrent);
				selection.selection = _backupSelection.slice();
			}
		}
	}

	// start the slideshow
	function start() {
		// collect the medias
		_medias.length = 0;
		_backupSelection.length = 0;
		var i = 0,
			media = undefined,
			lastRow = -1,
			index = undefined;

		// backup selection
		_backupCurrent = selection.current;
		_backupSelection = selection.selection.slice();

		// check settings to know which medias to show
		if (settings.get("Slideshow.Selection") === true && selection.selection.length > 0) {
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
			_mediaViewer.forceActiveFocus();
		}
	}

	// the timer used to control the selection
	Timer {
		id: timer
		interval: settings.get("Slideshow.Delay")
		repeat: true
		triggeredOnStart: false
		onTriggered: {
			// next indeex
			++_current;

			// loop or stop, depending on settings
			if (_current >= _medias.length) {
				if (settings.get("Slideshow.Loop") === true) {
					_current = 0;
				} else {
					stop();
					stateManager.state = "preview";
				}
			}

			// update the selection
			selection.setCurrent(_medias[_current]);

			// focus keeps getting stolen ...
			_mediaViewer.forceActiveFocus();
		}
	}
}
