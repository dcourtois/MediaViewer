#ifndef	__MEDIA_VIEWER_PCH_H__
#define	__MEDIA_VIEWER_PCH_H__


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

#include <QApplication>
#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QFileIconProvider>
#include <QFileInfo>
#include <QImage>
#include <QPixmap>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QSize>
#include <QString>

#if !defined(RETAIL)
#	include <QFileSystemWatcher>
#endif


//------------------------------------------------------------------------------
// MediaViewerLib

#include "MediaViewerLibPCH.h"
#include "Models/Media.h"


//------------------------------------------------------------------------------
// restore warnings

#if defined(_MSC_VER)
#	pragma warning ( pop )
#endif


#endif // __MEDIA_VIEWER_PCH_H__
