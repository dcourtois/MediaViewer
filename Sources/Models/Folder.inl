#ifndef __FOLDER_INL__
#define __FOLDER_INL__


namespace MediaViewer
{

	//!
	//! Get the folder's path
	//!
	const QString & Folder::GetPath(void) const
	{
		return m_Path;
	}

	//!
	//! Get the folder's name
	//!
	const QString & Folder::GetName(void) const
	{
		return m_Name;
	}

	//!
	//! Get the number of medias in this folder
	//!
	int Folder::GetMediaCount(void) const
	{
		return m_MediaCount;
	}

	//!
	//! Get the folder's parent
	//!
	const Folder * Folder::GetParent(void) const
	{
		return m_Parent;
	}

	//!
	//! Get the children
	//!
	const QVector< Folder * > & Folder::GetChildren(void) const
	{
		this->UpdateChildren();
		return m_Children;
	}

} // namespace MediaViewer


#endif // __FOLDER_INL__
