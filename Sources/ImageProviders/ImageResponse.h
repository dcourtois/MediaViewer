#ifndef IMAGE_PROVIDERS_IMAGE_RESPONSE_H
#define IMAGE_PROVIDERS_IMAGE_RESPONSE_H


namespace MediaViewer
{

	//!
	//! Implementation of QQuickImageResponse that can be used with QQuickAsyncImageProvider
	//!
	class ImageResponse
		: public QQuickImageResponse
		, public QRunnable
	{

	public:

		//! The type of the run callback function
		typedef std::function< QImage (std::atomic_bool &) > RunCallbackType;

		// constructors
		ImageResponse(void) = default;
		ImageResponse(RunCallbackType && run, QThreadPool * pool = QThreadPool::globalInstance());

		// reimplemented from QQuickImageResponse
		QQuickTextureFactory *	textureFactory(void) const final;
		void					cancel(void) final;

		// reimplemented from QRunnable
		void run(void) final;

	private:

		//! The callback to run to get the image
		RunCallbackType m_Run;

		//! True when the response needs to be cancelled
		std::atomic_bool m_Cancel;

		//! The image
		QImage m_Image;

	};

}


#endif
