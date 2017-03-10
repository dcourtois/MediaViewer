#include "MediaViewerPCH.h"
#include "ThumbnailProvider.h"
#include "Models/Media.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	ThumbnailProvider::ThumbnailProvider(void)
		: QQuickImageProvider(QQuickImageProvider::Image)
	{
	}

	//!
	//! Get a thumbnail from the given media
	//!
	QImage ThumbnailProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
	{
		// special handling of movies
		if (Media::GetType(id) == MediaViewer::Media::Type::Movie)
		{
			// extract the frame
			ThumbnailExtractor extractor(id, 0.33);
			QEventLoop loop;
			QObject::connect(&extractor, &ThumbnailExtractor::ready, &loop, &QEventLoop::quit);
			loop.exec();

			// set the size
			if (size != nullptr)
			{
				*size = extractor.GetThumbnail().size();
			}

			// and return the frame
			return extractor.GetThumbnail();
		}
		else
		{
			// load the image
			QImage image(id);

			// set the size
			int width = requestedSize.width() > 0 ? (requestedSize.width() > image.width() ? image.width() : requestedSize.width()) : 16;
			int height = requestedSize.height() > 0 ? (requestedSize.height() > image.height() ? image.height() : requestedSize.height()) : 16;
			if (size != nullptr)
			{
				size->setWidth(width);
				size->setHeight(height);
			}

			// create the thumbnail at the correct size
			return image.scaled(width, height, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);
		}
	}

	//!
	//! Get the thumbnail
	//!
	const QImage & ThumbnailExtractor::GetThumbnail(void) const
	{
		return m_Thumbnail;
	}

	//!
	//! Constructor
	//!
	//! @param path
	//!		Path of the video to extract from
	//!
	//! @param position
	//!		The position to seek before extracting the thumbnail. Between 0 and 1.
	//!
	ThumbnailExtractor::ThumbnailExtractor(const QString & path, double position)
		: m_Capture(0)
	{
		// configure the media player
		m_MediaPlayer.setVideoOutput(this);
		m_MediaPlayer.setVolume(0);
		m_MediaPlayer.setMedia(QUrl::fromLocalFile(path));

		// stops on error
		QObject::connect(&m_MediaPlayer, static_cast< void (QMediaPlayer::*)(QMediaPlayer::Error) >(&QMediaPlayer::error), [&](QMediaPlayer::Error) {
			m_MediaPlayer.stop();
			emit ready();
		});

		// start playing when the media is loaded
		QObject::connect(&m_MediaPlayer, &QMediaPlayer::mediaStatusChanged, [&, position](QMediaPlayer::MediaStatus status) {
			if (status == QMediaPlayer::MediaStatus::LoadedMedia)
			{
				m_MediaPlayer.setPosition(static_cast< qint64 >(m_MediaPlayer.duration() * position));
				m_MediaPlayer.play();
				m_Capture = 1;
			}
		});
	}

	//!
	//! Get a frame from a video
	//!
	bool ThumbnailExtractor::present(const QVideoFrame & frame)
	{
		// check if we need to capture
		if (m_Capture != 1)
		{
			return false;
		}

		// map the frame
		QVideoFrame newframe(frame);
		if (newframe.map(QAbstractVideoBuffer::MapMode::ReadOnly) == false)
		{
			return false;
		}

		// get the data
		const uchar * firstPixel = newframe.bits();
		if (firstPixel == nullptr)
		{
			return false;
		}

		// create the image
		int bytesperlines = newframe.bytesPerLine();
		int width = newframe.width();
		int height = newframe.height();
		m_Thumbnail = QImage(width, height, QImage::Format::Format_RGB888);
		if (newframe.pixelFormat() == QVideoFrame::PixelFormat::Format_ARGB32)
		{
			for (int x = 0; x < width; ++x)
			{
				for (int y = 0; y < height; ++y)
				{
					const uchar * pixel = firstPixel+ y * bytesperlines + x * 4;

					// note : even though pixel format is RGB, the real order seems to be BGR ...
					m_Thumbnail.setPixelColor(x, y, QColor(pixel[2], pixel[1], pixel[0]));
				}
			}
		}

		// unmap
		newframe.unmap();

		// stop playing and notify
		m_Capture = 0;
		m_MediaPlayer.stop();
		emit ready();

		return true;
	}

	//!
	//! Get the list of supported formats
	//!
	QList< QVideoFrame::PixelFormat > ThumbnailExtractor::supportedPixelFormats(QAbstractVideoBuffer::HandleType type) const
	{
		Q_UNUSED(type);
		QList< QVideoFrame::PixelFormat > formats;
		formats << QVideoFrame::PixelFormat::Format_ARGB32;
		return formats;
	}

} // namespace MediaViewer
