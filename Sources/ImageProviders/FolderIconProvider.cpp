#include "MediaViewerPCH.h"
#include "FolderIconProvider.h"
#include "ImageResponse.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	FolderIconProvider::FolderIconProvider(void)
	{
	}

	//!
	//! Get an image for the given id
	//!
	QQuickImageResponse * FolderIconProvider::requestImageResponse(const QString & id, const QSize & requestedSize)
	{
		return MT_NEW MediaViewer::ImageResponse([=] (void) -> QImage {
			// set the size
			int width = requestedSize.width() > 0 ? requestedSize.width() : 16;
			int height = requestedSize.height() > 0 ? requestedSize.height() : 16;

			// return the pixmap
			QMutexLocker lock(&m_Mutex);
			return m_IconProvider.icon(QFileInfo(id)).pixmap(width, height).toImage();
		});
	}

} // namespace MediaViewer
