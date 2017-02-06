#ifndef __THUMBNAIL_PROVIDER_H__
#define __THUMBNAIL_PROVIDER_H__


//!
//! Custom image provider used to get thumbnails from Medias
//!
class ThumbnailProvider
	: public QQuickImageProvider
{

public:

	ThumbnailProvider(void);

	// reimplemented from QQuickImageProvider
	QImage requestImage(const QString & id, QSize * size, const QSize & requestedSize) final;

private:

	//! A file icon provider
	QFileIconProvider m_IconProvider;

};


#endif // __THUMBNAIL_PROVIDER_H__
