#ifndef MODELS_FOLDER_MODEL_INL
#define MODELS_FOLDER_MODEL_INL


namespace MediaViewer
{

	//!
	//! Get the roots
	//!
	inline QQmlListProperty< Folder > FolderModel::GetRoots(void) const
	{
		return QQmlListProperty< Folder >(
			const_cast< QObject * >(static_cast< const QObject * >(this)),
			nullptr,
			&FolderModel::AddRoot,
			&FolderModel::GetRootCount,
			&FolderModel::GetRoot,
			&FolderModel::Clear
		);
	}

	//!
	//! Get the number of roots
	//!
	inline int FolderModel::GetRootCount(QQmlListProperty< Folder > * roots)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		return self->m_Roots.count();
	}

	//!
	//! Get a specific root
	//!
	inline Folder * FolderModel::GetRoot(QQmlListProperty< Folder > * roots, int index)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		return self->m_Roots.at(index);
	}

}


#endif
