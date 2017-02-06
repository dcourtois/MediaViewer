#ifndef __FOLDER_ICON_PROVIDER_H__
#define __FOLDER_ICON_PROVIDER_H__


//!
//! Custom image provider used to access the folder icons
//!
class FolderIconProvider
	: public QQuickImageProvider
{

public:

	FolderIconProvider(void);

	// reimplemented from QQuickImageProvider
	QImage requestImage(const QString & id, QSize * size, const QSize & requestedSize) final;

private:

	//! A file icon provider
	QFileIconProvider m_IconProvider;

};


#endif // __FOLDER_ICON_PROVIDER_H__
