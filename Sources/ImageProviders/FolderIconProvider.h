#ifndef __FOLDER_ICON_PROVIDER_H__
#define __FOLDER_ICON_PROVIDER_H__


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

} // namespace MediaViewer


#endif // __FOLDER_ICON_PROVIDER_H__
