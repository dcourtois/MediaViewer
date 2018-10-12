#include "MediaViewerPCH.h"
#include "MediaPreviewProvider.h"
#include "CppUtils/Hash.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	MediaPreviewProvider::MediaPreviewProvider(void)
		: QQuickImageProvider(QQuickImageProvider::Image)
		, m_UseCache(false)
		, m_CachePath(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/Cache")
	{
		QDir().mkpath(m_CachePath);
	}

	//!
	//! Get an image for the given id
	//!
	QImage MediaPreviewProvider::requestImage(const QString & id, QSize * size, const QSize & requestedSize)
	{
		// get the requested size
		int width = requestedSize.width() > 0 ? requestedSize.width() : -1;
		int height = requestedSize.height() > 0 ? requestedSize.height() : -1;

		// parse the id
		QRegularExpression address("(?<path>[^?]*)(\\?(?<width>\\d+)&(?<height>\\d+))?");
		QRegularExpressionMatch match = address.match(id);
		QString path;
		if (match.hasMatch() == true)
		{
			path = match.captured("path");
			const QString w = match.captured("width");
			if (w.isEmpty() == false)
			{
				width = w.toInt();
			}
			const QString h = match.captured("height");
			if (h.isEmpty() == false)
			{
				height = h.toInt();
			}
		}

		// ensure the image exists
		if (QFile::exists(path) == false)
		{
			return QImage();
		}

		// get the hash corresponding to this thumbnail
		uint32_t hash = Hash::Combine({
			Hash::Jenkins(path.toLocal8Bit().data(), size_t(path.size())),
			static_cast< unsigned int >(width),
			static_cast< unsigned int >(height)
		});

		// get the source file info and a few information
		const QFileInfo source(path);
		const QString extension(source.suffix());
		const QString cacheFolder	= this->GetCacheFolder(hash);
		const QString cacheName		= cacheFolder + QString("%1").arg(hash);
		const QString thumbnailName	= cacheName + '.' + extension;
		const QString descName		= cacheFolder + ".json";

		// the image
		QImage image;

		// check if we have a thumbnail already
		QFile descFile(descName);
		if (descFile.open(QIODevice::ReadOnly) == true)
		{
			const QJsonDocument desc(QJsonDocument::fromJson(descFile.readAll()));
			const QJsonObject root = desc.object();
			if (source.size() == root["size"].toInt() && source.lastModified().toString() == root["date"].toString())
			{
				image = QImage(thumbnailName);
			}
		}

		// didn't load the image, read it
		if (image.isNull() == true)
		{
			QImageReader imageReader(path);
			imageReader.setAutoDetectImageFormat(true);
			imageReader.setAutoTransform(true);
			if (width != -1 && height != -1)
			{
				const QSize size = imageReader.size();
				if (width < size.width() || height < size.height())
				{
					if (size.width() > size.height())
					{
						imageReader.setScaledSize({
							width,
							int(width * (size.height() / double(size.width())))
						});
					}
					else
					{
						imageReader.setScaledSize({
							int(height * (size.width() / double(size.height()))),
							height
						});
					}
				}
			}
			image = imageReader.read();
		}

		// update the size
		if (size != nullptr)
		{
			*size = image.size();
		}

		// save to cache
		QDir().mkpath(cacheFolder);
		image.save(thumbnailName);

		// write description
		QJsonObject root;
		root["size"] = source.size();
		root["date"] = source.lastModified().toString();
		QFile desc(descName);
		if (desc.open(QIODevice::WriteOnly) == true)
		{
			desc.write(QJsonDocument(root).toJson());
		}

		// return the image
		return image;
	}

	//!
	//! Compute a cache folder for a given hash
	//!
	QString MediaPreviewProvider::GetCacheFolder(uint32_t hash) const
	{
		QString hashName = QString("%2").arg(hash);
		QString folder = m_CachePath + '/';
		for (int i = 0; i < hashName.size(); i += 4)
		{
			if (hashName.size() - i < 4)
			{
				break;
			}
			folder += hashName[i];
			folder += hashName[i + 2];
			folder += hashName[i + 3];
			folder += hashName[i + 4];
			folder += '/';
		}
		return folder;
	}

	//!
	//! Get the current cache usage.
	//!
	bool MediaPreviewProvider::GetUseCache(void) const
	{
		return m_UseCache;
	}

	//!
	//! Set whether the provider should cache the generated thumbnails or not.
	//!
	void MediaPreviewProvider::SetUseCache(bool value)
	{
		if (m_UseCache != value)
		{
			m_UseCache = value;
			emit useCacheChanged(value);
		}
	}

	//!
	//! Get the current cache folder path
	//!
	const QString & MediaPreviewProvider::GetCachePath(void) const
	{
		return m_CachePath;
	}

} // namespace MediaViewer
