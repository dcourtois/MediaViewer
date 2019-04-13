#ifndef IMAGE_PROVIDERS_FOLDER_ICON_PROVIDER_H
#define IMAGE_PROVIDERS_FOLDER_ICON_PROVIDER_H


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


#endif
