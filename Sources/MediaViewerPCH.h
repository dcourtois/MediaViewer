#ifndef MEDIA_VIEWER_PCH_H
#define MEDIA_VIEWER_PCH_H


//------------------------------------------------------------------------------
// disable a few warnings before including Qt

#if defined(_MSC_VER)
#	pragma warning ( push )
#	pragma warning ( disable : 4127 )	// conditional expression is constant
#	pragma warning ( disable : 4251 )	// needs to have dll-interface to be used by clients of class
#	pragma warning ( disable : 4512 )	// assignment operator could not be generated
#	pragma warning ( disable : 4800 )	// forcing value to bool 'true' or 'false' (performance warning)
#endif


//------------------------------------------------------------------------------
// Qt

#include <QAbstractVideoSurface>
#include <QApplication>
#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileIconProvider>
#include <QFileInfo>
#include <QIcon>
#include <QImage>
#include <QImageReader>
#include <QList>
#include <QMediaPlayer>
#include <QObject>
#include <QPainter>
#include <QPixmap>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlExtensionPlugin>
#include <QQuickImageProvider>
#include <QQuickStyle>
#include <QRunnable>
#include <QSize>
#include <QString>
#include <QVector>
#include <QWidget>
#include <QtDebug>
#include <QtQml>

#if !defined(RETAIL)
#	include <QFileSystemWatcher>
#endif


//------------------------------------------------------------------------------
// on Windows, to be able to output to the Visual Studio debuggers

#if defined(WINDOWS)
#	define WIN32_LEAN_AND_MEAN
#	include <Windows.h>
#endif



//------------------------------------------------------------------------------
// restore warnings

#if defined(_MSC_VER)
#	pragma warning ( pop )
#endif


//------------------------------------------------------------------------------
// STL

#include <algorithm>
#include <atomic>
#include <cctype>
#include <functional>


//------------------------------------------------------------------------------
// Utils


#include "CppUtils/MemoryTracker.h"
#include "CppUtils/STLUtils.h"
#include "QtUtils/Settings.h"


#endif // MEDIA_VIEWER_PCH_H
