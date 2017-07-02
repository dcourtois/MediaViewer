#ifndef __FOLDER_MODEL_INL__
#define __FOLDER_MODEL_INL__


namespace MediaViewer
{

	//!
	//! Get the roots
	//!
	QQmlListProperty< Folder > FolderModel::GetRoots(void) const
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
	int FolderModel::GetRootCount(QQmlListProperty< Folder > * roots)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		return self->m_Roots.count();
	}

	//!
	//! Get a specific root
	//!
	Folder * FolderModel::GetRoot(QQmlListProperty< Folder > * roots, int index)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		return self->m_Roots.at(index);
	}

} // namespace MediaViewer


#endif // __FOLDER_MODEL_INL__
