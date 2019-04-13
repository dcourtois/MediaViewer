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

		// constructors
		ImageResponse(void);
		ImageResponse(std::function< QImage (void) > && callback, bool start = true);

		// reimplemented from QQuickImageResponse
		QQuickTextureFactory * textureFactory(void) const final;

		// reimplemented from QRunnable
		void run(void) final;

	private:

		//! The callback to run to get the image
		std::function< QImage (void) > m_Callback;

		//! The image
		QImage m_Image;

	};

}


#endif
