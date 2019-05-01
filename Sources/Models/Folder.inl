#ifndef MODELS_FOLDER_INL
#define MODELS_FOLDER_INL


namespace MediaViewer
{

	//!
	//! Get the folder's path
	//!
	inline const QString & Folder::GetPath(void) const
	{
		return m_Path;
	}

	//!
	//! Get the folder's name
	//!
	inline const QString & Folder::GetName(void) const
	{
		return m_Name;
	}

	//!
	//! Get the number of medias in this folder
	//!
	inline int Folder::GetMediaCount(void) const
	{
		return m_MediaCount;
	}

	//!
	//! Get the folder's parent
	//!
	inline const Folder * Folder::GetParent(void) const
	{
		return m_Parent;
	}

	//!
	//! Get the children
	//!
	inline const QVector< Folder * > & Folder::GetChildren(void) const
	{
		this->UpdateChildren();
		return m_Children;
	}

	//!
	//! Normalize a path so that it's easier to test things
	//!
	inline QString Folder::Normalize(const QString & path)
	{
		if (path.size() == 0)
		{
			return path;
		}
		QString result(path);
		result = result.replace('\\', '/');
		if (result.back() == '/')
		{
			result.remove(result.size() - 1, 1);
			if (result.back() == ':')
			{
				return result + '/';
			}
		}
		return result;
	}

}


#endif
