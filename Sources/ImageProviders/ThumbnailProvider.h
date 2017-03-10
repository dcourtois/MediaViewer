#ifndef __THUMBNAIL_PROVIDER_H__
#define __THUMBNAIL_PROVIDER_H__


namespace MediaViewer
{

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

	//!
	//! Class used to extract a preview from a video
	//!
	class ThumbnailExtractor
		: public QAbstractVideoSurface
	{

		Q_OBJECT

	signals:

		void ready(void);

	public:

		ThumbnailExtractor(const QString & path, double position);

		// C++ API
		const QImage & GetThumbnail(void) const;

		// reimplemented from QAbstractVideoSurface
		bool present(const QVideoFrame & frame) final;
		QList< QVideoFrame::PixelFormat > supportedPixelFormats(QAbstractVideoBuffer::HandleType type = QAbstractVideoBuffer::NoHandle) const final;

	private:

		//! The media player used to retrieve video thumbnails
		QMediaPlayer m_MediaPlayer;

		//! The thumbnail
		QImage m_Thumbnail;

		//! When true, will capture the next available frame
		QAtomicInt m_Capture;

	};

} // namespace MediaViewer


#endif // __THUMBNAIL_PROVIDER_H__
