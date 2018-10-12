#include "MediaViewerPCH.h"
#include "RegisterQMLTypes.h"
#include "ImageProviders/FolderIconProvider.h"
#include "ImageProviders/MediaPreviewProvider.h"
#include "Utils/Cursor.h"
#include "Utils/FileSystem.h"

//
// those are exposed to QML through QQmlContext::setContextProperty, which
// does not take ownership, so we'll need to delete them we leaving the app.
//
static Cursor *		cursor		= nullptr;
static FileSystem *	fileSystem	= nullptr;

//!
//! Set the application engine with our main QML file
//!
void Setup(QApplication & app, QQmlApplicationEngine & engine)
{
	// register QML types
	MediaViewer::RegisterQMLTypes();

	// create data that's shared with QML
	auto * mediaProvider	= MT_NEW MediaViewer::MediaPreviewProvider;
	cursor					= MT_NEW Cursor;
	fileSystem				= MT_NEW FileSystem;

	// set the image provider for the folders
	engine.addImageProvider("FolderIcon", MT_NEW MediaViewer::FolderIconProvider);
	engine.addImageProvider("MediaPreview", mediaProvider);

	// set a few global QML helpers
	engine.rootContext()->setContextProperty("cursor", cursor);
	engine.rootContext()->setContextProperty("fileSystem", fileSystem);
	engine.rootContext()->setContextProperty("mediaProvider", mediaProvider);

	// expose the list of drives to QML
	QVariantList drives;
#if defined(WINDOWS)
	// user folders
	for (auto drive : QStandardPaths::standardLocations(QStandardPaths::HomeLocation))
	{
		drives << drive;
	}

	// drives
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

	// cleanup
	MT_DELETE cursor;
	MT_DELETE fileSystem;

#if MEMORY_CHECK == 1

	// we no longer need to track memory
	MT_SET_ENABLED(false);

	// dump memory leaks
	auto chunks = MemoryTracker::Instance().GetTrackedChunks();
	if (chunks.empty() == true)
	{
		printf("No memory leaks, congratulations !\n");
	}
	else
	{
		printf("Memory leak detected - %llu block%s still allocated :\n", chunks.size(), chunks.size() > 1 ? "s" : "");
		for (const auto & entry : chunks)
		{
			printf(
				"%s(%d): [%lli] %llu bytes at location %p\n",
				entry.second.Filename,
				entry.second.Line,
				entry.second.AllocationID,
				entry.second.Bytes,
				entry.first
			);
		}
	}

#endif // MEMORY_CHECK == 1

	return code;
}
