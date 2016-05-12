#include "MediaViewerPCH.h"
#include "Utils/FolderIconProvider.h"


#if defined(DEBUG)

//!
//! The QML compilation result
//!
QString compilation;

//!
//! Temporary message handler used to catch QML compilation errors
//!
void messageHandler(QtMsgType /* type */, const QMessageLogContext & /* context */, const QString & message)
{
	compilation += message + "\n";
}

#endif

//!
//! Set the application engine with our main QML file
//!
void setup(QQmlApplicationEngine *& engine)
{
	// re-create the engine
	delete engine;
	engine = new QQmlApplicationEngine();

	// setup
#if defined(DEBUG)
	engine->addImportPath(QDir(qApp->applicationDirPath() + "/../../../../MediaViewer/Sources/QML/").canonicalPath());
#endif
	engine->addImageProvider("FolderIcon", new FolderIconProvider);

	// expose the list of drives to QML
	QVariantList drives;
	for (auto drive : QDir::drives())
	{
		drives << drive.absolutePath();
	}
	engine->rootContext()->setContextProperty("drives", drives);

	// set the source
#if defined(DEBUG)
	// install a message handler to catch compilation errors
	compilation.clear();
	qInstallMessageHandler(messageHandler);

	// load the main file
	engine->load("Main.qml");

	// restore the default message handler
	qInstallMessageHandler(nullptr);

	// check errors
	if (engine->rootObjects().empty() == true)
	{
		// display the errors
		engine->loadData(QString(
			"import QtQuick 2.3\n"
			"import QtQuick.Window 2.2\n"
			"Window {\n"
			"	visible: true\n"
			"	width: 1000\n"
			"	height: 500\n"
			"	Text {\n"
			"		FontLoader {\n"
			"			id: sourceCode\n"
			"			source: \"qrc:///fonts/SourceCodePro-Regular\"\n"
			"		}\n"
			"		font.family: sourceCode.name\n"
			"		font.pixelSize: 12\n"
			"		text: \"" + compilation.replace("\"", "\\\"") + "\"\n"
			"		anchors.fill: parent\n"
			"		anchors.topMargin: 10\n"
			"		anchors.leftMargin: 10\n"
			"	}\n"
			"}\n"
		).toLatin1());
	}
	else
	{
		for (auto line : compilation.split("\n"))
		{
			qDebug() << line;
		}
	}
#else
	engine->load(QUrl("qrc:/Main.qml"));
#endif
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

#if defined(DEBUG)
		// install a file system watcher to be able to hot-reload the QML when it changes
		QFileSystemWatcher watcher;
		watcher.addPath("AnimatedImageViewer.qml");
		watcher.addPath("FolderBrowser.qml");
		watcher.addPath("ImageViewer.qml");
		watcher.addPath("Main.qml");
		watcher.addPath("MediaBrowser.qml");
		watcher.addPath("MediaSelection.qml");
		watcher.addPath("MediaViewer.qml");
		watcher.addPath("MovieViewer.qml");
		watcher.addPath("StateManager.qml");
		watcher.addPath("WindowSettings.qml");
		watcher.addPath("WindowState.qml");
		QObject::connect(&watcher, &QFileSystemWatcher::fileChanged, [&] (const QString &) {
			setup(engine);
		});
#endif

		// run the application
		code = app.exec();

		// cleanup
		delete engine;
	}

	return code;
}
