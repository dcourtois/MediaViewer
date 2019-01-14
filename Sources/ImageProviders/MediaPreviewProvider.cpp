#include "MediaViewerPCH.h"
#include "MediaPreviewProvider.h"
#include "CppUtils/Hash.h"


namespace MediaViewer
{

	//! Default cache folder
	inline QString GetDefaultCachePath(void)
	{
		return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/Cache";
	}

	//!
	//! Constructor
	//!
	MediaPreviewProvider::MediaPreviewProvider(void)
		: QQuickImageProvider(QQuickImageProvider::Image)
		, m_UseCache(g_Settings.value("imageProvider.useCache", true).toBool())
		, m_CachePath(g_Settings.value("imageProvider.cachePath", GetDefaultCachePath()).toString())
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
		if (m_UseCache == true && descFile.open(QIODevice::ReadOnly) == true)
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

		// update cache if needed
		if (m_UseCache == true)
		{
			// ensure the folder exists
			QDir().mkpath(cacheFolder);

			// save the image
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
			g_Settings.setValue("imageProvider.useCache", m_UseCache);
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

	//!
	//! Set the cache path.
	//!
	//! @param path
	//!		The new path. The old cache images will be moved to the new path,
	//!		and if the path is empty, it will fall back to the default location.
	//!
	void MediaPreviewProvider::SetCachePath(const QString & path)
	{
		QString newPath = path.size() != 0 ? path : GetDefaultCachePath();
		newPath.replace('\\', '/');
		if (newPath.section('/', -1, -1) != "Cache")
		{
			newPath += "/Cache";
		}
		if (newPath != m_CachePath)
		{
			QDir(newPath).removeRecursively();
			if (QDir().rename(m_CachePath, newPath) == true)
			{
				m_CachePath = newPath;
				g_Settings.setValue("imageProvider.cachePath", m_CachePath);
				emit cachePathChanged(m_CachePath);
			}
		}
	}

	//!
	//! Remove the thumbnail cache folder
	//!
	void MediaPreviewProvider::clearCache(void) const
	{
		QDir(m_CachePath).removeRecursively();
	}

} // namespace MediaViewer
