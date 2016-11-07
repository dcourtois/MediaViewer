#include "MediaViewerPCH.h"
#include "Utils/FolderIconProvider.h"
#include "Utils/Cursor.h"


//!
//! Set the application engine with our main QML file
//!
void Setup(QApplication & app, QQmlApplicationEngine & engine)
{
	// set the image provider for the folders
	engine.addImageProvider("FolderIcon", new FolderIconProvider);

	// set the cursor manager
	engine.rootContext()->setContextProperty("cursor", new Cursor);

	// expose the list of drives to QML
	QVariantList drives;
	for (auto drive : QDir::drives())
	{
		drives << drive.absolutePath();
	}
	engine.rootContext()->setContextProperty("drives", drives);

	// open the initial folder / media
	QStringList args = app.arguments();
	engine.rootContext()->setContextProperty("initMedia", "");
	engine.rootContext()->setContextProperty("initFolder", "");
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
