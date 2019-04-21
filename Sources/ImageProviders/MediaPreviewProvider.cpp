#include "MediaViewerPCH.h"
#include "MediaPreviewProvider.h"
#include "ImageResponse.h"
#include "CppUtils/Hash.h"
#include "Utils/Job.h"


namespace MediaViewer
{

	//!
	//! Constructor
	//!
	MediaPreviewProvider::MediaPreviewProvider(void)
		: m_UseCache(Settings::Get< bool >("MediaPreviewProvider.UseCache"))
		, m_CachePath(Settings::Get< QString >("MediaPreviewProvider.CachePath"))
		, m_CancelTime(QTime::currentTime())
	{
		QDir().mkpath(m_CachePath);
	}

	//!
	//! Destructor
	//!
	MediaPreviewProvider::~MediaPreviewProvider(void)
	{
		// ensure all tasks are correctly closed before continuing
		this->cancelPending();
		m_Pool.clear();
		m_Pool.waitForDone();
	}

	//!
	//! Default cache folder
	//!
	QString MediaPreviewProvider::DefaultCachePath(void)
	{
		return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/Cache";
	}

	//!
	//! Get an image for the given id
	//!
	QQuickImageResponse * MediaPreviewProvider::requestImageResponse(const QString & id, const QSize & requestedSize)
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

		// create the image response
		return MT_NEW MediaViewer::ImageResponse([=] (std::atomic_bool & cancel) -> QImage {

			// avoid wasting time
			if (QTime::currentTime() < m_CancelTime)
			{
				return QImage();
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
			const QString cacheName		= QString("%1/%2").arg(cacheFolder).arg(static_cast< qulonglong >(hash));
			const QString descName		= QString("%1.json").arg(cacheName);
			const QString thumbnail		= QString("%1.jpg").arg(cacheName);

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
					return QImage(root["thumbnail"].toString());
				}
			}

			// the image is no in the cache, load it
			QImage image;
			if (cancel == false && image.isNull() == true)
			{
				image = this->GetImagePreview(path, width, height, cancel);
			}
			if (cancel == false && image.isNull() == true)
			{
				image = this->GetMoviePreview(path, width, height, cancel);
			}

			// couldn't load it, stop here
			if (image.isNull() == true)
			{
				return image;
			}

			// update cache if needed
			if (cancel == false && m_UseCache == true)
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
					else
					{
						qDebug() << "failed writing preview metadata " << descName << " to disk";
					}
				}
				else
				{
					qDebug() << "failed writing image preview " << thumbnail << " to disk";
				}
			}

			// return the image
			return image;

		}, &m_Pool);
	}

	//!
	//! Compute a cache folder for a given hash
	//!
	QString MediaPreviewProvider::GetCacheFolder(uint32_t hash) const
	{
		QString hashName = QString("%1").arg(static_cast< uint >(hash), 8, 10, static_cast< QChar >('0'));
		Q_ASSERT(hashName.size() >= 8);
		return QString("%1/%2%3%4%5/%6%7%8%9").arg(m_CachePath)
			.arg(hashName[0]).arg(hashName[1]).arg(hashName[2]).arg(hashName[3])
			.arg(hashName[4]).arg(hashName[5]).arg(hashName[6]).arg(hashName[7]);
	}
	
	//!
	//! Try to get a preview for a static image
	//!
	QImage MediaPreviewProvider::GetImagePreview(const QString & path, int width, int height, std::atomic_bool & cancel)
	{
		// check if we can read the image
		QImageReader imageReader;
		imageReader.setAutoDetectImageFormat(true);
		imageReader.setAutoTransform(true);
		imageReader.setFileName(path);
		if (cancel == true || imageReader.canRead() == false)
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
		return cancel == false ? imageReader.read() : QImage();
	}

	//!
	//! Try to get a preview for a movie
	//!
	QImage MediaPreviewProvider::GetMoviePreview(const QString & path, int width, int height, std::atomic_bool & cancel)
	{
		// create stuff needed for the video capture
		QEventLoop loop;
		QMediaPlayer * player = MT_NEW QMediaPlayer();
		VideoCapture * output = MT_NEW VideoCapture(path, loop, cancel);

		// check for invalid media errors
		QObject::connect(player, &QMediaPlayer::mediaStatusChanged, [&] (QMediaPlayer::MediaStatus status) {
			if (status == QMediaPlayer::InvalidMedia)
			{
				qDebug("%s invalid media", qPrintable(path));
				loop.quit();
			}
		});

		// on error, just stop the loop
		QObject::connect(player, static_cast< void (QMediaPlayer::*)(QMediaPlayer::Error) >(&QMediaPlayer::error), [&] (QMediaPlayer::Error error) {
			qDebug() << "failed generating preview for " << path << " with error " <<  error;
			loop.quit();
		});

		// when the position changes, enabled capture and start playing
		bool first = true;
		QObject::connect(player, &QMediaPlayer::positionChanged, [&] (qint64 position) {
			Q_UNUSED(position);
			if (cancel == true)
			{
				loop.quit();
			}
			if (first == true)
			{
				output->Capture(10);
				player->play();
				first = false;
			}
		});

		// setup the player
		if (cancel == false)
		{
			player->setVideoOutput(output);
			player->setMuted(true);
			player->setMedia(QUrl::fromLocalFile(path));
		}

		// wait for the capture
		loop.exec();

		// cleanup
		player->stop();

		// get the captured frame
		QImage result = cancel == false && output->GetFrame().isNull() == false ?
			output->GetFrame().scaled({ width, height }, Qt::AspectRatioMode::KeepAspectRatio, Qt::TransformationMode::SmoothTransformation) :
			output->GetFrame();

		// cleanup
		MT_DELETE player;
		MT_DELETE output;

		// done
		return result;
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
			Settings::Set("MediaPreviewProvider.UseCache", m_UseCache);
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
		QString newPath = path.size() != 0 ? path : DefaultCachePath();
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
			Settings::Set("MediaPreviewProvider.CachePath", m_CachePath);
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
	//! Call this when you know all the preview are going to be re-created (typically when changing the thumbnail size)
	//!
	void MediaPreviewProvider::cancelPending(void)
	{
		m_CancelTime = QTime::currentTime();
	}


	//!
	//! Constructor
	//!
	VideoCapture::VideoCapture(const QString & path, QEventLoop & loop, std::atomic_bool & cancel)
		: m_Path(path)
		, m_Loop(loop)
		, m_Cancel(cancel)
		, m_Capture(false)
		, m_Retries(0)
	{
	}

	//!
	//! Enable capture for the next presented frame
	//!
	void VideoCapture::Capture(int retries)
	{
		m_Capture = true;
		m_Retries = retries;
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
		if (m_Capture == false)
		{
			return true;
		}

		// avoid re-capturing
		if (m_Retries.fetch_sub(1) <= 0)
		{
			m_Capture = false;
		}

		// check the frame
		if (source.isValid() == false)
		{
			qDebug() << m_Path << " - invalid frame - " << this->error();
			if (m_Capture == false)
			{
				m_Loop.quit();
			}
			return false;
		}

		// check cancellation
		if (m_Cancel == true)
		{
			m_Loop.quit();
			return false;
		}

		// map our frame (we need to make a local copy since we receive the frame as an immutable reference)
		QVideoFrame frame(source);
		if (frame.map(QAbstractVideoBuffer::MapMode::ReadOnly) == false)
		{
			qDebug() << m_Path << " - failed mapping frame - " << this->error();
			if (m_Capture == false)
			{
				m_Loop.quit();
			}
			return false;
		}

		// check cancellation
		if (m_Cancel == true)
		{
			frame.unmap();
			m_Loop.quit();
			return false;
		}

		if (source.pixelFormat() != QVideoFrame::Format_Invalid)
		{
			// setup the image
			QImage capturedFrame(frame.width(), frame.height(), QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat()));

			// check the size of the source frame and destination capture
			const int srcBytes = frame.mappedBytes();
			const int dstBytes = capturedFrame.byteCount();

			// check cancellation
			if (m_Cancel == true)
			{
				frame.unmap();
				m_Loop.quit();
				return false;
			}

			// depending on those sizes, extracting the frame is done differently
			if (dstBytes == srcBytes)
			{
				// simple case, the image can be copied in one go
				memcpy(capturedFrame.bits(), frame.bits(), srcBytes);
			}
			else if (dstBytes < srcBytes)
			{
				// more complex case, it seems in some cases there is some padding at the end of each
				// lines, so we need to copy them one at a time
				uchar * src = frame.bits();
				uchar * dst = capturedFrame.bits();
				const int srcBytesPerLine = frame.bytesPerLine();
				const int dstBytesPerLine = dstBytes / capturedFrame.height();
				for (int i = 0, iend = frame.height(); i < iend; ++i)
				{

					// check cancellation
					if (m_Cancel == true)
					{
						frame.unmap();
						m_Loop.quit();
						return false;
					}

					memcpy(dst, src, dstBytesPerLine);
					src += srcBytesPerLine;
					dst += dstBytesPerLine;
				}
			}
			else
			{
				// ok here I don't know what the hell's going on
				Q_ASSERT(false && "incompatible sizes");
			}

			// store the captured frame
			m_Frame = capturedFrame;
		}
		else
		{
			qDebug() << m_Path << " - invalid format - " << source.pixelFormat();
			if (m_Capture == false)
			{
				m_Loop.quit();
			}
			return false;
		}

		// release the frame
		frame.unmap();

		// stop the loop
		m_Loop.quit();

		// and done !
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
			QVideoFrame::Format_RGB32,
			QVideoFrame::Format_RGB555,
			QVideoFrame::Format_RGB565,
			QVideoFrame::Format_BGR24,
			QVideoFrame::Format_BGR32,
			QVideoFrame::Format_BGR555,
			QVideoFrame::Format_BGR565,
			QVideoFrame::Format_BGRA32,
			QVideoFrame::Format_BGRA32_Premultiplied,
			QVideoFrame::Format_BGRA5658_Premultiplied,
			QVideoFrame::Format_ARGB32,
			QVideoFrame::Format_ARGB32_Premultiplied,
			QVideoFrame::Format_ARGB8565_Premultiplied,
			QVideoFrame::Format_Jpeg
		};
	}

}
