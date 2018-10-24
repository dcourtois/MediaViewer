#ifndef IMAGE_PROVIDERS_MEDIA_PREVIEW_PROVIDER_H
#define IMAGE_PROVIDERS_MEDIA_PREVIEW_PROVIDER_H


namespace MediaViewer
{

	//!
	//! Custom image provider used to generate previews of images, optionally handling caching
	//!
	class MediaPreviewProvider
		: public QObject
		, public QQuickImageProvider
	{

		Q_OBJECT

		Q_PROPERTY(bool useCache READ GetUseCache WRITE SetUseCache NOTIFY useCacheChanged)
		Q_PROPERTY(QString cachePath READ GetCachePath WRITE SetCachePath NOTIFY cachePathChanged)

	signals:

		void	useCacheChanged(bool useCache);
		void	cachePathChanged(QString cachePath);

	public:

		MediaPreviewProvider(void);

		// reimplemented from QQuickImageProvider
		QImage requestImage(const QString & id, QSize * size, const QSize & requestedSize) final;

		// public C++ API
		bool				GetUseCache(void) const;
		void				SetUseCache(bool value);
		const QString &		GetCachePath(void) const;
		void				SetCachePath(const QString & path);

		// public QML API
		Q_INVOKABLE void	clearCache(void) const;

	private:

		// private API
		QString GetCacheFolder(uint32_t hash) const;

		//! true if we should cache the thumbnails, false otherwise
		bool m_UseCache;

		//! path to the thumbnail cache
		QString m_CachePath;

	};

} // namespace MediaViewer


#endif // IMAGE_PROVIDERS_MEDIA_PREVIEW_PROVIDER_H
