#include "MediaViewerPCH.h"
#include "ThumbnailProvider.h"


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
	// set the size
	int width = requestedSize.width() > 0 ? requestedSize.width() : 16;
	int height = requestedSize.height() > 0 ? requestedSize.height() : 16;
	if (size != nullptr)
	{
		size->setWidth(width);
		size->setHeight(height);
	}

	// special handling of movies
	if (MediaViewerLib::Media::GetType(id) == MediaViewerLib::Media::Type::Movie)
	{
		return QImage();
	}
	else
	{
		return QImage(id).scaled(width, height, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);
	}
}
