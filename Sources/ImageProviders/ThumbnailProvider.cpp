#include "MediaViewerPCH.h"
#include "ThumbnailProvider.h"
#include "Models/Media.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	ThumbnailProvider::ThumbnailProvider(QObject * parent)
		: QQuickImageProvider(QQuickImageProvider::Image)
		, QAbstractVideoSurface(parent)
	{
	}

	//!
	//! Get a thumbnail from the given media
	//!
	QImage ThumbnailProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
	{
		// set the size
		int width = requestedSize.width() > 0 ? requestedSize.width() : 16;
		int height = requestedSize.height() > 0 ? requestedSize.height() : 16;
		if (size != nullptr)
		{
			size->setWidth(width);
			size->setHeight(height);
		}

		// special handling of movies
		if (Media::GetType(id) == MediaViewer::Media::Type::Movie)
		{
			return QImage();
		}
		else
		{
			return QImage(id).scaled(width, height, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);
		}
	}

	//!
	//! Get a frame from a video
	//!
	bool ThumbnailProvider::present(const QVideoFrame & frame)
	{
		return false;
	}

	//!
	//! Get the list of supported formats
	//!
	QList< QVideoFrame::PixelFormat > ThumbnailProvider::supportedPixelFormats(QAbstractVideoBuffer::HandleType type) const
	{
		return QList< QVideoFrame::PixelFormat >();
	}

} // namespace MediaViewer
