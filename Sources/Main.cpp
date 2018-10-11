#include "MediaViewerPCH.h"
#include "RegisterQMLTypes.h"
#include "ImageProviders/FolderIconProvider.h"
#include "Utils/Cursor.h"
#include "Utils/FileSystem.h"


//!
//! Set the application engine with our main QML file
//!
void Setup(QApplication & app, QQmlApplicationEngine & engine)
{
	// register QML types
	MediaViewer::RegisterQMLTypes();

	// set the image provider for the folders
	engine.addImageProvider("FolderIcon", new MediaViewer::FolderIconProvider);

	// set a few global QML helpers
	engine.rootContext()->setContextProperty("cursor", new Cursor);
	engine.rootContext()->setContextProperty("fileSystem", new FileSystem);

	// expose the list of drives to QML
	QVariantList drives;
#if defined(WINDOWS)
	for (auto drive : QDir::drives())
	{
		drives << drive.absolutePath();
	}
#elif defined(LINUX)
	// get the user home
	for (auto drive : QStandardPaths::standardLocations(QStandardPaths::HomeLocation))
	{
		drives << drive;
	}

	// hacky way of getting the mounted volumes (local harddrives, usb keys, etc.)
	for (const QStorageInfo & storage : QStorageInfo::mountedVolumes())
	{
		if (storage.isRoot() == true ||
			storage.isReadOnly() == true ||
			storage.device().startsWith("/dev/sd") == false)
		{
			continue;
		}
		drives << storage.rootPath();
	}
#elif defined(MACOS)
	// get the user home
	for (auto drive : QStandardPaths::standardLocations(QStandardPaths::HomeLocation))
	{
		drives << drive;
	}
#else
	static_assert(false, "initialize drives for your platform");
#endif
	engine.rootContext()->setContextProperty("drives", drives);

	// open the initial folder / media
	QStringList args = app.arguments();
	if (args.size() > 1)
	{
		QString path = args[1];
		QFileInfo info(path);
		if (info.isFile())
		{
			engine.rootContext()->setContextProperty("initFolder", info.absolutePath());
			engine.rootContext()->setContextProperty("initMedia", info.absoluteFilePath());
		}
		else if (info.isDir())
		{
			engine.rootContext()->setContextProperty("initFolder", info.absoluteFilePath());
		}
	}
	else
	{
		engine.rootContext()->setContextProperty("initMedia", "");
		engine.rootContext()->setContextProperty("initFolder", "");
	}

	// set the source
	engine.load(QUrl("qrc:/Main.qml"));
}

//!
//! Entry point of the application
//!
int main(int argc, char *argv[])
{
	int code = -1;
	{
		// create the application
		QApplication app(argc, argv);
		app.setOrganizationName("Citron");
		app.setOrganizationDomain("pcitron.fr");
		app.setApplicationName("MediaViewer");
		app.setApplicationVersion("0.1");

		// create and setup application engine
		QQmlApplicationEngine engine;
		Setup(app, engine);

		// run the application
		code = app.exec();
	}

	return code;
}
