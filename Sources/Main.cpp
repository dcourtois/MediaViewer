#include "ImageProviders/FolderIconProvider.h"
#include "ImageProviders/MediaPreviewProvider.h"
#include "QtUtils/QuickView.h"
#include "QtUtils/Settings.h"
#include "RegisterQMLTypes.h"
#include "Utils/Cursor.h"
#include "Utils/FileSystem.h"

#include <QApplication>
#include <QQmlContext>
#include <QQuickStyle>
#include <QDir>
#include <QStandardPaths>

// header-only libs implementations
#define MEMORY_TRACKER_IMPLEMENTATION
#include "CppUtils/MemoryTracker.h"

// those are exposed to QML through QQmlContext::setContextProperty, which
// does not take ownership, so we'll need to delete them we leaving the app.
static Settings *		settings		= nullptr;
static Cursor *			cursor			= nullptr;
static FileSystem *		fileSystem		= nullptr;

//!
//! Message handler used to redirect QML log, warnings, etc. to the debug output.
//!
void MessageHandler(QtMsgType, const QMessageLogContext &, const QString & message)
{
#if defined(QT_NO_DEBUG)
	Q_UNUSED(message);
#else
#	if defined(OutputDebugString)
	OutputDebugStringA(qPrintable(message.back() == '\n' ? message : message + '\n'));
#	else
	printf("%s\n", qPrintable(message));
#	endif
#endif
}

//!
//! Set the application engine with our main QML file
//!
void Setup(QApplication & app, QuickView & view)
{
	// register QML types
	MediaViewer::RegisterQMLTypes();

	// the settings. These need to be created first since some other parts of the
	// code will check them to initialize correctly
	settings = MT_NEW Settings;
	settings->Init("FileSystem.DeletePermanently",			false);
	settings->Init("General.RestoreLastVisitedFolder",		true);
	settings->Init("General.LastVisitedFolder",				QString(""));
	settings->Init("Media.SortBy",							0);
	settings->Init("Media.SortOrder",						0);
	settings->Init("Media.ThumbnailSize",					170);
	settings->Init("Media.ShowLabel",						true);
	settings->Init("Slideshow.Loop",						true);
	settings->Init("Slideshow.Selection",					true);
	settings->Init("Slideshow.Delay",						2000);
	settings->Init("Movie.Fullscreen",						true);
	settings->Init("Movie.Loop",							0);
	settings->Init("Movie.Muted",							true);
	settings->Init("Movie.Volume",							0.5);
	settings->Init("MediaPreviewProvider.UseCache",			true);
	settings->Init("MediaPreviewProvider.CachePath",		MediaViewer::MediaPreviewProvider::DefaultCachePath());

	// create data that's shared with QML
	auto * mediaProvider	= MT_NEW MediaViewer::MediaPreviewProvider;
	cursor					= MT_NEW Cursor;
	fileSystem				= MT_NEW FileSystem;

	// set the image provider for the folders
	QQmlEngine & engine = *view.engine();
	engine.addImageProvider("FolderIcon", MT_NEW MediaViewer::FolderIconProvider);
	engine.addImageProvider("MediaPreview", mediaProvider);

	// set a few global QML helpers
	engine.rootContext()->setContextProperties({
		{ "settings",		QVariant::fromValue(settings) },
		{ "cursor",			QVariant::fromValue(cursor) },
		{ "fileSystem",		QVariant::fromValue(fileSystem) },
		{ "mediaProvider",	QVariant::fromValue(mediaProvider) },
		{ "rootView",		QVariant::fromValue(&view) }
	});

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
			engine.rootContext()->setContextProperty("initMedia", "");
		}
		else
		{
			engine.rootContext()->setContextProperty("initMedia", "");
			engine.rootContext()->setContextProperty("initFolder", "");
		}

	}
	else
	{
		engine.rootContext()->setContextProperty("initMedia", "");
		engine.rootContext()->setContextProperty("initFolder", "");
	}

	// configure the view
	view.SetPersistence(
		QuickView::PersistenceFlags::Maximized |
		QuickView::PersistenceFlags::Position |
		QuickView::PersistenceFlags::Size
	);

	// set the source
	view.setSource(QUrl("qrc:/Main.qml"));

	// and restore
	view.Restore(1000, 750, QWindow::Visibility::Windowed);
	view.raise();
	view.requestActivate();
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
		app.setOrganizationName(ORGANIZATION_NAME);
		app.setApplicationName(APPLICATION_NAME);
		app.setApplicationVersion(APPLICATION_VERSION);

		// install our message handler
		qInstallMessageHandler(MessageHandler);

		// set style
		QQuickStyle::setStyle("Material");

		// create and setup our view
		QuickView * view = MT_NEW QuickView();
		Setup(app, *view);

		// run the application
		code = app.exec();

		// cleanup (order is important)
		MT_DELETE cursor;
		MT_DELETE fileSystem;
		MT_DELETE view;
	}

	// end of cleanup
	MT_DELETE settings;

	// log memory leaks
	MT_SHUTDOWN(qDebug);

	return code;
}
