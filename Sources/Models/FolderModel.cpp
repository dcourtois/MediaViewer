#include "MediaViewerPCH.h"
#include "FolderModel.h"
#include "Folder.h"


namespace MediaViewer
{

	//!
	//! Constructor.
	//!
	FolderModel::FolderModel(QObject * parent)
		: QAbstractItemModel(parent)
	{
	}

	//!
	//! Destructor.
	//!
	FolderModel::~FolderModel()
	{
		for (auto root : m_Roots)
		{
			MT_DELETE root;
		}
	}

	//!
	//! Get the index from a path
	//!
	QModelIndex FolderModel::getIndexByPath(const QString & path) const
	{
		Folder * folder = nullptr;
		int row = 0;
		QStringList tokens = QString(path).replace('\\', '/').split('/');

		// remove trailing slash
		if (tokens.last().isEmpty() == true)
		{
			tokens.pop_back();
		}

		// reconstruct the path from the beginning
		QString current;
		for (const auto & token : tokens)
		{
			// update the current path
			current = (current.isEmpty() == true ? token : current + token) + "/";

			// try to find the next folder
			const QVector< Folder * > & folders = folder == nullptr ? m_Roots : folder->GetChildren();
			folder = nullptr;
			for (int i = 0; i < folders.size(); ++i)
			{
				if (QDir(folders.at(i)->GetPath()) == QDir(current))
				{
					row = i;
					folder = folders.at(i);
					break;
				}
			}
		}

		// return the result
		return folder == nullptr ? QModelIndex() : this->createIndex(row, 0, folder);

	}

	//!
	//! Add a new root
	//!
	void FolderModel::AddRoot(QQmlListProperty< Folder > * roots, Folder * root)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		self->beginInsertRows(QModelIndex(), self->m_Roots.size(), self->m_Roots.size());
		self->m_Roots.push_back(MT_NEW Folder(*root));
		self->endInsertRows();
	}

	//!
	//! Clear all the roots
	//!
	void FolderModel::Clear(QQmlListProperty< Folder > * roots)
	{
		FolderModel * self = static_cast< FolderModel * >(roots->object);
		self->beginResetModel();
		for (auto root : self->m_Roots)
		{
			MT_DELETE root;
		}
		self->m_Roots.clear();
		self->endResetModel();
	}

	//!
	//! Get the root paths
	//!
	QStringList FolderModel::GetRootPaths(void) const
	{
		QStringList paths;
		for (auto root : m_Roots)
		{
			paths << root->GetPath();
		}
		return paths;
	}

	//!
	//! Get the root paths
	//!
	void FolderModel::SetRootPaths(const QStringList & paths)
	{
		// clear
		this->beginResetModel();
		for (auto root : m_Roots)
		{
			MT_DELETE root;
		}
		m_Roots.clear();

		// add the new roots
		for (const QString & path : paths)
		{
			m_Roots.push_back(MT_NEW Folder(path));
		}

		// done
		this->endResetModel();
	}

	//!
	//! Get the roles supported by this model
	//!
	QHash< int, QByteArray > FolderModel::roleNames(void) const
	{
		return {
			{ Qt::DisplayRole,		"name" },
			{ Qt::UserRole,			"path" },
			{ Qt::UserRole + 1,		"mediaCount" },
			{ Qt::UserRole + 2,		"folder" }
		};
	}

	//!
	//! Get the data for a given cell and row.
	//!
	QVariant FolderModel::data(const QModelIndex & index, int role) const
	 {
		if (index.isValid() == false)
		{
			return QVariant();
		}

		Folder * node = static_cast< Folder * >(index.internalPointer());
		if (node == nullptr)
		{
			return QVariant();
		}

		switch (role)
		{
			case Qt::DisplayRole:		return node->GetName();
			case Qt::UserRole:			return node->GetPath();
			case Qt::UserRole + 1:		return node->GetMediaCount();
			case Qt::UserRole + 2:		return QVariant::fromValue(node);
			default:					return QVariant();
		}
	}

	//!
	//! Get an index for a row, column and parent.
	//!
	//! @param row
	//!		Parent relative row index.
	//!
	QModelIndex FolderModel::index(int row, int column, const QModelIndex & parent) const
	{
		if (parent.isValid())
		{
			return this->createIndex(row, column, static_cast< Folder * >(parent.internalPointer())->GetChildren().at(row));
		}

		if (row < m_Roots.size())
		{
			return this->createIndex(row, column, m_Roots.at(row));
		}

		return QModelIndex();
	}

	//!
	//! Get the parent of a cell.
	//!
	QModelIndex FolderModel::parent(const QModelIndex & index) const
	{
		if (index.isValid() == false)
		{
			return QModelIndex();
		}

		Folder * folder = static_cast< Folder * >(index.internalPointer());
		if (folder == nullptr || folder->GetParent() == nullptr)
		{
			return QModelIndex();
		}

		// get the parent
		folder = const_cast< Folder * >(folder->GetParent());

		// find its row index (relative to its parent)
		const QVector< Folder * > & children = folder->GetParent() ? folder->GetParent()->GetChildren() : m_Roots;
		int row = IndexOf(children, folder);
		return this->createIndex(row, 0, const_cast< Folder * >(folder));
	}

	//!
	//! Get the number of row (e.g. children) of a cell.
	//!
	int FolderModel::rowCount(const QModelIndex & parent) const
	{
		if (parent.isValid() == false)
		{
			return m_Roots.size();
		}

		Folder * node = static_cast< Folder * >(parent.internalPointer());
		return node != nullptr ? node->GetChildren().size() : 0;
	}

	//!
	//! Get the number of columns.
	//!
	int FolderModel::columnCount(const QModelIndex & /* parent */) const
	{
		return 1;
	}

} // namespace MediaViewer
