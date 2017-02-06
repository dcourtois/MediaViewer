#ifndef __THUMBNAIL_PROVIDER_H__
#define __THUMBNAIL_PROVIDER_H__


namespace MediaViewer
{

	//!
	//! Custom image provider used to get thumbnails from Medias
	//!
	class ThumbnailProvider
		: public QQuickImageProvider
		, public QAbstractVideoSurface
	{

	public:

		ThumbnailProvider(QObject * parent = nullptr);

		// reimplemented from QQuickImageProvider
		QImage requestImage(const QString & id, QSize * size, const QSize & requestedSize) final;

		// reimplemented from QAbstractVideoSurface
		bool present(const QVideoFrame & frame) final;
		QList< QVideoFrame::PixelFormat > supportedPixelFormats(QAbstractVideoBuffer::HandleType type = QAbstractVideoBuffer::NoHandle) const final;

	private:

		//! A file icon provider
		QFileIconProvider m_IconProvider;

	};

} // namespace MediaViewer


#endif // __THUMBNAIL_PROVIDER_H__
