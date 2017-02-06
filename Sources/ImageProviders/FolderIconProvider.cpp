#include "MediaViewerPCH.h"
#include "FolderIconProvider.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	FolderIconProvider::FolderIconProvider(void)
		: QQuickImageProvider(QQuickImageProvider::Image)
	{
	}

	//!
	//! Get an image for the given id
	//!
	QImage FolderIconProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
	{
		// set the size
		int width = requestedSize.width() > 0 ? requestedSize.width() : 16;
		int height = requestedSize.height() > 0 ? requestedSize.height() : 16;
		if (size != nullptr)
		{
			size->setWidth(width);
			size->setHeight(height);
		}

		// return the pixmap
		return m_IconProvider.icon(QFileInfo(id)).pixmap(width, height).toImage();
	}

} // namespace MediaViewer
