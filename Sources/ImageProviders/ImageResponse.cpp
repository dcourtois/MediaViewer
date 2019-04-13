#include "MediaViewerPCH.h"
#include "ImageResponse.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	ImageResponse::ImageResponse(void)
	{
	}

	//!
	//! Constructor
	//!
	ImageResponse::ImageResponse(std::function< QImage (void) > && callback, bool start)
		: m_Callback(callback)
	{
		// image responses are deleted once the image has been used. And since thread pools
		// auto-delete runnables by default, we need to disable this.
		setAutoDelete(false);

		// start if required
		if (start == true)
		{
			QThreadPool::globalInstance()->start(this);
		}
	}

	//!
	//! Create a texture factory for our image
	//!
	QQuickTextureFactory * ImageResponse::textureFactory(void) const
	{
		return QQuickTextureFactory::textureFactoryForImage(m_Image);
	}

	//!
	//! Run the job
	//!
	void ImageResponse::run(void)
	{
		m_Image = m_Callback();
		emit finished();
	}

}
