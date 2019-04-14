#include "MediaViewerPCH.h"
#include "ImageResponse.h"
#include "MediaPreviewProvider.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	ImageResponse::ImageResponse(RunCallbackType && run,  QThreadPool * pool)
		: m_Run(run)
		, m_Cancel(false)
	{
		// thread pool automatically delete jobs when done, but this is also an image response which
		// is deleted when the image has been generated, so we need to disable the automatic deletion
		// by the thread pool to avoid deleting this twice
		setAutoDelete(false);

		// auto-start
		pool->start(this);
	}

	//!
	//! Create a texture factory for our image
	//!
	QQuickTextureFactory * ImageResponse::textureFactory(void) const
	{
		return QQuickTextureFactory::textureFactoryForImage(m_Image);
	}

	//!
	//! Cancel is required
	//!
	void ImageResponse::cancel(void)
	{
		m_Cancel = true;
	}

	//!
	//! Run the job
	//!
	void ImageResponse::run(void)
	{
		m_Image = m_Run(m_Cancel);
		emit finished();
	}

}
