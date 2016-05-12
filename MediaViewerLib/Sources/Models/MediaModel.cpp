#include "MediaViewerLibPCH.h"
#include "MediaModel.h"
#include "Media.h"
#include "Utils/Misc.h"


namespace MediaViewerLib
{

	//!
	//! Constructor.
	//!
	MediaModel::MediaModel(QObject * parent)
		: QAbstractItemModel(parent)
		, m_Dirty(false)
	{
	}

	//!
	//! Destructor.
	//!
	MediaModel::~MediaModel(void)
	{
		this->Clear();
	}

	//!
	//! Get the current root's path.
	//!
	const QString & MediaModel::GetRoot(void) const
	{
		return m_Root;
	}

	//!
	//! Set the root's path.
	//!
	void MediaModel::SetRoot(const QString & path)
	{
		if (path == m_Root || QDir(path).exists() == false)
		{
			return;
		}

		this->beginResetModel();
		this->Clear();

		m_Root = path;
		m_Dirty = true;

		this->endResetModel();

		// notify
		emit rootChanged(m_Root);
	}

	//!
	//! Clear the medias
	//!
	void MediaModel::Clear(void)
	{
		for (Media * media : m_Medias)
		{
			DELETE media;
		}
		m_Medias.clear();
	}

	//!
	//! Get the medias in the root folder
	//!
	const QVector< Media * > &	MediaModel::GetMedias(void) const
	{
		if (m_Dirty == true)
		{
			QDir dir(m_Root);
			for (const auto & file : dir.entryList(QDir::Files, QDir::Name))
			{
				if (Media::IsMedia(file) == true)
				{
					m_Medias.push_back(NEW Media(dir.absoluteFilePath(file)));
					QQmlEngine::setObjectOwnership(m_Medias.back(), QQmlEngine::CppOwnership);
				}
			}

			// reset the dirty flag
			m_Dirty = false;
		}
		return m_Medias;
	}

	//!
	//! Get the index from a path
	//!
	int MediaModel::getIndexByPath(const QString & path) const
	{
		int index = 0;
		for (const Media * media : m_Medias)
		{
			if (media->GetPath() == path)
			{
				return index;
			}
			++index;
		}
		return -1;
	}

	//!
	//! Get the model index from a path
	//!
	QModelIndex MediaModel::getModelIndexByPath(const QString & path) const
	{
		int index = this->getIndexByPath(path);
		return index != -1 ? this->createIndex(index, 0, const_cast< Media * >(m_Medias[index])) : QModelIndex();
	}

	//!
	//! Get the model previous index
	//!
	QModelIndex MediaModel::getPreviousModelIndex(const QModelIndex & index) const
	{
		if (index.isValid() == false || index.row() <= 1)
		{
			return QModelIndex();
		}
		return this->createIndex(index.row() - 1, 0, m_Medias.at(index.row() - 1));
	}

	//!
	//! Get the next model index
	//!
	QModelIndex MediaModel::getNextModelIndex(const QModelIndex & index) const
	{
		if (index.isValid() == false || index.row() >= m_Medias.size() - 1)
		{
			return QModelIndex();
		}
		return this->createIndex(index.row() + 1, 0, m_Medias.at(index.row() + 1));
	}

	//!
	//! Get a media
	//!
	Media * MediaModel::getMedia(const QModelIndex & index) const
	{
		return index.isValid() == true ? static_cast< Media * >(index.internalPointer()) : nullptr;
	}

	//!
	//! Get the index of a media
	//!
	int MediaModel::getIndex(const QModelIndex & index) const
	{
		return index.isValid() == true ? index.row() : -1;
	}

	//!
	//! Get the roles supported by this model
	//!
	QHash< int, QByteArray > MediaModel::roleNames(void) const
	{
		QHash< int, QByteArray > roles;
		roles.insert(Qt::DisplayRole,	"name");
		roles.insert(Qt::UserRole,		"path");
		return roles;
	}

	//!
	//! Get the data for a given cell and row.
	//!
	QVariant MediaModel::data(const QModelIndex & index, int role) const
	 {
		if (index.isValid() == false)
		{
			return QVariant();
		}

		Media * media = static_cast< Media * >(index.internalPointer());
		Q_ASSERT(media != nullptr);

		switch (role)
		{
			case Qt::DisplayRole:	return media->GetName();
			case Qt::UserRole:		return media->GetPath();
			default:				return QVariant();
		}
	}

	//!
	//! Get an index for a row, column and parent.
	//!
	//! @param row
	//!		Parent relative row index.
	//!
	QModelIndex MediaModel::index(int row, int column, const QModelIndex & parent) const
	{
		Q_UNUSED(parent);
		Q_ASSERT(parent.isValid() == false);
		return this->createIndex(row, column, this->GetMedias().at(row));
	}

	//!
	//! Get the parent of a cell.
	//!
	QModelIndex MediaModel::parent(const QModelIndex & /* index */) const
	{
		return QModelIndex();
	}

	//!
	//! Get the number of row (e.g. children) of a cell.
	//!
	int MediaModel::rowCount(const QModelIndex & parent) const
	{
		return parent.isValid() == true ? 0 : this->GetMedias().size();
	}

	//!
	//! Get the number of columns.
	//!
	int MediaModel::columnCount(const QModelIndex & /* parent */) const
	{
		return 1;
	}

} // namespace MediaViewerLib
