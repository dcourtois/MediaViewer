#include "MediaViewerPCH.h"
#include "RegisterQMLTypes.h"
#include "Models/FolderModel.h"
#include "Models/Folder.h"
#include "Models/MediaModel.h"
#include "Models/Media.h"


namespace MediaViewer
{

	//!
	//! Register stuff exposed to QML
	//!
	void RegisterQMLTypes(void)
	{
		// version of the plugin
		int major = 0;
		int minor = 1;

		// register for use with QVariant and property system
		qRegisterMetaType< Folder * >("Folder*");
		qRegisterMetaType< Media * >("Media*");

		// register our QML types
		qmlRegisterType< Folder >("MediaViewer", major, minor, "Folder");
		qmlRegisterType< FolderModel >("MediaViewer", major, minor, "FolderModel");
		qmlRegisterType< Media >("MediaViewer", major, minor, "Media");
		qmlRegisterType< MediaModel >("MediaViewer", major, minor, "MediaModel");
	}

} // namespace MediaViewer
