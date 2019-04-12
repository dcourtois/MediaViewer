#include "MediaViewerPCH.h"
#include "MediaPreviewProvider.h"
#include "CppUtils/Hash.h"


namespace MediaViewer
{

	//! Supported movie extensions
	static const QVector< QString > movieExtensions = {
		".mp4"
	};

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
		uint32_t hash = Hash::Combine(
			Hash::Jenkins(path.toLocal8Bit().data(), size_t(path.size())),
			static_cast< unsigned int >(width),
			static_cast< unsigned int >(height)
		);

		// get the source file info and a few information
		const QFileInfo source(path);
		const QString extension(source.suffix());
		const QString cacheFolder	= this->GetCacheFolder(hash);
		const QString cacheName		= cacheFolder + QString("%1").arg(hash);
		const QString descName		= cacheFolder + ".json";

		// the image
		QImage image;

		// check if we have a thumbnail already
		QFile descFile(descName);
		if (m_UseCache == true && descFile.open(QIODevice::ReadOnly) == true)
		{
			const QJsonDocument desc(QJsonDocument::fromJson(descFile.readAll()));
			const QJsonObject root = desc.object();
			if (source.size() == root["size"].toInt() &&
				source.lastModified().toString() == root["date"].toString() &&
				QFile::exists(root["thumbnail"].toString()))
			{
				image = QImage(root["thumbnail"].toString());
			}
		}

		// didn't load the image, create it
		QString thumbnail = cacheName + '.' + extension;
		if (image.isNull() == true)
		{
			image = this->GetImagePreview(path, width, height);
		}
		if (image.isNull() == true)
		{
			image = this->GetMoviePreview(path, width, height);
			thumbnail += ".jpg";
		}
		if (image.isNull() == true)
		{
			return image;
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
			if (image.save(thumbnail) == true)
			{
				// write description
				QJsonObject root;
				root["size"] = source.size();
				root["date"] = source.lastModified().toString();
				root["thumbnail"] = thumbnail;
				QFile desc(descName);
				if (desc.open(QIODevice::WriteOnly) == true)
				{
					desc.write(QJsonDocument(root).toJson());
				}
			}
			else
			{
				qDebug("failed writing image preview %s to disk", qPrintable(thumbnail));
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
	//! Try to get a preview for a static image
	//!
	QImage MediaPreviewProvider::GetImagePreview(const QString & path, int width, int height)
	{
		// check if we can read the image
		QImageReader imageReader;
		imageReader.setAutoDetectImageFormat(true);
		imageReader.setAutoTransform(true);
		imageReader.setFileName(path);
		if (imageReader.canRead() == false)
		{
			return QImage();
		}

		// configure the reader if we had a required size
		if (width != -1 && height != -1)
		{
			const QSize imageSize = imageReader.size();
			if (imageSize.width() > 0 || imageSize.height() > 0)
			{
				if (width < imageSize.width() || height < imageSize.height())
				{
					if (imageSize.width() > imageSize.height())
					{
						imageReader.setScaledSize({
							width,
							int(width * (imageSize.height() / double(imageSize.width())))
						});
					}
					else
					{
						imageReader.setScaledSize({
							int(height * (imageSize.width() / double(imageSize.height()))),
							height
						});
					}
				}
			}
		}

		// return the preview
		return imageReader.read();
	}

	//!
	//! Try to get a preview for a movie
	//!
	QImage MediaPreviewProvider::GetMoviePreview(const QString & path, int width, int height)
	{
		Q_UNUSED(path);
		Q_UNUSED(width);
		Q_UNUSED(height);

		// create data needed for the video capture
		QEventLoop loop;
		QMediaPlayer player;
		VideoCapture output(loop);
		bool capture = false;

		// when metadata is available, set the position to a third of the movie length
		QObject::connect(&player, &QMediaObject::metaDataAvailableChanged, [&] (bool available) {
			if (available == true)
			{
				capture = true;
				player.setPosition(player.metaData("Duration").toInt() / 3);
			}
		});

		// on error, just stop the loop
		QObject::connect(&player, static_cast< void (QMediaPlayer::*)(QMediaPlayer::Error) >(&QMediaPlayer::error), [&] (QMediaPlayer::Error error) {
			qDebug("failed generating preview for %s with error %d", qPrintable(path), error);
			loop.quit();
		});

		// when the position changes, enabled capture and start playing
		QObject::connect(&player, &QMediaPlayer::positionChanged, [&] (qint64 position) {
			Q_UNUSED(position);
			if (capture == true)
			{
				output.Capture();
				player.play();
			}
		});

		// setup the player
		player.setVideoOutput(&output);
		player.setMuted(true);
		player.setMedia(QUrl::fromLocalFile(path));

		// wait for the capture
		loop.exec();

		// cleanup
		player.stop();
		player.setVideoOutput(static_cast< QAbstractVideoSurface * >(nullptr));

		// return the captured frame
		return output.GetFrame().scaled({ width, height }, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation);
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
	//!		The new path. If empty, the default path will be used.
	//!
	void MediaPreviewProvider::SetCachePath(const QString & path)
	{
		// get the path
		QString newPath = path.size() != 0 ? path : GetDefaultCachePath();
		newPath.replace('\\', '/');
		if (newPath.section('/', -1, -1) != "Cache")
		{
			newPath += "/Cache";
		}

		// if different, update
		if (newPath != m_CachePath)
		{
			// ensure the new path doesn't exist
			QDir(newPath).removeRecursively();

			// try moving the old cache if it exists
			if (QFile::exists(m_CachePath) == true)
			{
				if (QDir().rename(m_CachePath, newPath) == false)
				{
					QDir(m_CachePath).removeRecursively();
					QDir().mkdir(newPath);
				}
			}
			else
			{
				QDir().mkdir(newPath);
			}

			// update the path and notify
			m_CachePath = newPath;
			g_Settings.setValue("imageProvider.cachePath", m_CachePath);
			emit cachePathChanged(m_CachePath);
		}
	}

	//!
	//! Remove the thumbnail cache folder
	//!
	void MediaPreviewProvider::clearCache(void) const
	{
		if (QDir(m_CachePath).removeRecursively() == true)
		{
			QDir().mkdir(m_CachePath);
		}
	}


	//!
	//! Constructor
	//!
	VideoCapture::VideoCapture(QEventLoop & loop)
		: m_Loop(loop)
		, m_Capture(false)
	{
	}

	//!
	//! Enable capture for the next presented frame
	//!
	void VideoCapture::Capture(void)
	{
		m_Capture = true;
	}

	//!
	//! Get the captured frame
	//!
	const QImage & VideoCapture::GetFrame(void) const
	{
		return m_Frame;
	}

	//!
	//! Reimplemented from QAbstractVideoSurface. This is called whenever a new frame is available.
	//!
	bool VideoCapture::present(const QVideoFrame & source)
	{
		if (m_Capture == true)
		{
			// map our frame (we need to make a local copy since we receive the frame as an immutable reference)
			QVideoFrame frame(source);
			if (frame.map(QAbstractVideoBuffer::MapMode::ReadOnly) == false)
			{
				return false;
			}

			// create the image and copy the pixels
			m_Frame = QImage(frame.width(), frame.height(), QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat()));
			memcpy(m_Frame.bits(), frame.bits(), frame.mappedBytes());

			// release the frame
			frame.unmap();

			// stop the loop
			m_Loop.quit();
		}

		return true;
	}

	//!
	//! Reimplemented from QAbstractVideoSurface.
	//!
	QList< QVideoFrame::PixelFormat > VideoCapture::supportedPixelFormats(QAbstractVideoBuffer::HandleType type) const
	{
		Q_UNUSED(type);
		return {
			QVideoFrame::Format_RGB24,
			QVideoFrame::Format_ARGB32
		};
	}

} // namespace MediaViewer
