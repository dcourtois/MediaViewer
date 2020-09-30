#pragma once

#include <QFileIconProvider>
#include <QMutex>
#include <QQuickAsyncImageProvider>


namespace MediaViewer
{

	//!
	//! Custom image provider used to access the folder icons
	//!
	class FolderIconProvider
		: public QQuickAsyncImageProvider
	{

	public:

		FolderIconProvider(void);

		// reimplemented from QQuickAsyncImageProvider
		QQuickImageResponse * requestImageResponse(const QString & id, const QSize & requestedSize) final;

	private:

		//! A file icon provider
		QFileIconProvider m_IconProvider;

		//! Used to protect the icon provider
		QMutex m_Mutex;

	};

}
