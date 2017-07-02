#ifndef __MEDIA_INL__
#define __MEDIA_INL__


namespace MediaViewer
{

	//!
	//! Compare 2 medias (compare their path)
	//!
	bool Media::operator == (const Media & other) const
	{
		return m_Path == other.m_Path;
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
	//! Get the media's last modification date
	//!
	const QDateTime & Media::GetDate(void) const
	{
		return m_Date;
	}

	//!
	//! Get the media's name
	//!
	uint64_t Media::GetSize(void) const
	{
		return m_Size;
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

} // namespace MediaViewer


#endif // __MEDIA_INL__
