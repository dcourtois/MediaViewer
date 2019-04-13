#ifndef MODELS_MEDIA_INL
#define MODELS_MEDIA_INL


namespace MediaViewer
{

	//!
	//! Get the media's path
	//!
	inline const QString & Media::GetPath(void) const
	{
		return m_Path;
	}

	//!
	//! Get the media's name
	//!
	inline const QString & Media::GetName(void) const
	{
		return m_Name;
	}

	//!
	//! Get the media's last modification date
	//!
	inline const QDateTime & Media::GetDate(void) const
	{
		return m_Date;
	}

	//!
	//! Get the media's name
	//!
	inline uint64_t Media::GetSize(void) const
	{
		return m_Size;
	}

	//!
	//! Get the media's type
	//!
	inline Media::Type Media::GetType(void) const
	{
		return m_Type;
	}

	//!
	//! Checks if a file is a supported media
	//!
	inline bool Media::IsMedia(const QString & filename)
	{
		return GetType(filename) != Type::NotSupported;
	}

}


#endif
