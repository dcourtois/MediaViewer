#include "MediaViewerPCH.h"
#include "Utils/FolderIconProvider.h"


//!
//! Set the application engine with our main QML file
//!
void setup(QQmlApplicationEngine *& engine)
{
	// re-create the engine
	delete engine;
	engine = new QQmlApplicationEngine();

	// setup
	engine->addImageProvider("FolderIcon", new FolderIconProvider);

	// expose the list of drives to QML
	QVariantList drives;
	for (auto drive : QDir::drives())
	{
		drives << drive.absolutePath();
	}
	engine->rootContext()->setContextProperty("drives", drives);

	// set the source
	engine->load(QUrl("qrc:/Main.qml"));
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
		QQmlApplicationEngine * engine = nullptr;
		setup(engine);

		// run the application
		code = app.exec();

		// cleanup
		delete engine;
	}

	return code;
}
