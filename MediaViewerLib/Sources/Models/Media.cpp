#include "MediaViewerLibPCH.h"
#include "MediaModel.h"
#include "Media.h"


namespace MediaViewerLib
{

	//!
	//! Private list of supported media extension, and their associated MediaType
	//!
	const static QHash< QString, Media::Type > SupportedMediaExtensions = {
		// static images
		{ "jpg",	Media::Type::Image },
		{ "jpeg",	Media::Type::Image },
		{ "tif",	Media::Type::Image },
		{ "tiff",	Media::Type::Image },
		{ "png",	Media::Type::Image },
		{ "dds",	Media::Type::Image },
		{ "svg",	Media::Type::Image },

		// animated images
		{ "gif",	Media::Type::AnimatedImage },

		// movies
		{ "wmv",	Media::Type::Movie },
		{ "mkv",	Media::Type::Movie },
		{ "avi",	Media::Type::Movie }
	};

	//!
	//! Constructor.
	//!
	Media::Media(const QString & path)
		: m_Path(path)
		, m_Name(QFileInfo(path).fileName())
		, m_Type(GetType(path))
	{
	}

	//!
	//! Copy constructor
	//!
	Media::Media(const Media & other)
		: m_Path(other.m_Path)
		, m_Name(other.m_Name)
		, m_Type(other.m_Type)
	{
	}

	//!
	//! Destructor.
	//!
	Media::~Media(void)
	{
	}

	//!
	//! Get the media's path
	//!
	const QString & Media::GetPath(void) const
	{
		return m_Path;
	}

	//!
	//! Get the media's name
	//!
	const QString & Media::GetName(void) const
	{
		return m_Name;
	}

	//!
	//! Get the media's type
	//!
	Media::Type Media::GetType(void) const
	{
		return m_Type;
	}

	//!
	//! Checks if a file is a supported media
	//!
	bool Media::IsMedia(const QString & filename)
	{
		return GetType(filename) != Type::NotSupported;
	}

	//!
	//! Get the type of a file
	//!
	Media::Type Media::GetType(const QString & filename)
	{
		QString extension = filename.section('.', -1, -1).toLower();
		auto type = SupportedMediaExtensions.find(extension);
		return type != SupportedMediaExtensions.end() ? type.value() : Type::NotSupported;
	}

} // namespace MediaViewerLib
