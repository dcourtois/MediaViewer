#ifndef	__MEDIA_VIEWER_LIB_PCH_H__
#define	__MEDIA_VIEWER_LIB_PCH_H__


//-----------------------------------------------------------------------------
// export dll

#ifdef EXPORT_DLL
#	define MEDIA_VIEWER_LIB_EXPORT			__declspec(dllexport)
#	define MEDIA_VIEWER_LIB_IMPORT_TEMPLATE
#else
#	define MEDIA_VIEWER_LIB_EXPORT			__declspec(dllimport)
#	define MEDIA_VIEWER_LIB_IMPORT_TEMPLATE	extern
#endif


//------------------------------------------------------------------------------
// disable a few warnings before including Qt

#if defined(_MSC_VER)
#	pragma warning ( push )
#	pragma warning ( disable : 4127 )	// conditional expression is constant
#	pragma warning ( disable : 4251 )	// needs to have dll-interface to be used by clients of class
#	pragma warning ( disable : 4512 )	// assignment operator could not be generated
#	pragma warning ( disable : 4714 )	// function 'function' marked as __forceinline not inlined
#	pragma warning ( disable : 4800 )	// forcing value to bool 'true' or 'false' (performance warning)
#endif


//------------------------------------------------------------------------------
// Qt

#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileIconProvider>
#include <QIcon>
#include <QImage>
#include <QList>
#include <QObject>
#include <QPainter>
#include <QQmlExtensionPlugin>
#include <QQuickImageProvider>
#include <QRunnable>
#include <QtDebug>
#include <QtQml>
#include <QString>
#include <QVector>


//------------------------------------------------------------------------------
// restore warnings

#if defined(_MSC_VER)
#	pragma warning ( pop )
#endif


//------------------------------------------------------------------------------
// STL

#include <algorithm>
#include <functional>


//------------------------------------------------------------------------------
// memory leak detection

#include "Utils/Memory.h"


#endif // __MEDIA_VIEWER_LIB_PCH_H__
