#include "MediaViewerPCH.h"
#include "MediaModel.h"
#include "Media.h"
#include "Utils/Misc.h"


namespace MediaViewer
{

	//!
	//! Constructor.
	//!
	MediaModel::MediaModel(QObject * parent)
		: QAbstractItemModel(parent)
		, m_Dirty(false)
		, m_SortBy(SortBy::Name)
		, m_SortOrder(SortOrder::Ascending)
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

		// reset the model
		this->beginResetModel();
		this->Clear();
		m_Root = path;
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
		m_Dirty = true;
	}

	//!
	//! Get the medias in the root folder
	//!
	const QVector< Media * > &	MediaModel::GetMedias(void) const
	{
		if (m_Dirty == true)
		{
			QDir dir(m_Root);
			for (const auto & file : dir.entryList(QDir::Files, QDir::NoSort))
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
	//! Get the sort type
	//!
	MediaModel::SortBy MediaModel::GetSortBy(void) const
	{
		return m_SortBy;
	}

	//!
	//! Set the sort type
	//!
	void MediaModel::SetSortBy(SortBy by)
	{
		if (m_SortBy != by)
		{
			m_SortBy = by;
			emit sortByChanged(by);
		}
	}

	//!
	//! Get the sort direction
	//!
	MediaModel::SortOrder MediaModel::GetSortOrder(void) const
	{
		return m_SortOrder;
	}

	//!
	//! Set the sort direction
	//!
	void MediaModel::SetSortOrder(SortOrder order)
	{
		if (m_SortOrder != order)
		{
			m_SortOrder = order;
			emit sortOrderChanged(order);
		}
	}

	//!
	//! Sort the model
	//!
	void MediaModel::Sort(void)
	{
		this->beginResetModel();

		switch (m_SortBy)
		{
			case SortBy::Name:
				if (m_SortOrder == SortOrder::Ascending)
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetName() < r->GetName(); });
				}
				else
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetName() > r->GetName(); });
				}
				break;

			case SortBy::Date:
				if (m_SortOrder == SortOrder::Ascending)
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetDate() < r->GetDate(); });
				}
				else
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetDate() > r->GetDate(); });
				}
				break;

			case SortBy::Size:
				if (m_SortOrder == SortOrder::Ascending)
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetSize() < r->GetSize(); });
				}
				else
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetSize() > r->GetSize(); });
				}
				break;

			case SortBy::Type:
				if (m_SortOrder == SortOrder::Ascending)
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetType() < r->GetType(); });
				}
				else
				{
					Utils::Sort(m_Medias, [](const Media * l, const Media * r) -> bool { return l->GetType() > r->GetType(); });
				}
				break;
		}

		this->endResetModel();
	}

	//!
	//! The QML invokable sort method
	//!
	void MediaModel::sort(void)
	{
		this->Sort();
	}

	//!
	//! Get the index from a path
	//!
	int MediaModel::getIndexByPath(const QString & path) const
	{
		int index = 0;
		for (const Media * media : this->GetMedias())
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
		return index != -1 ? this->createIndex(index, 0, const_cast< Media * >(this->GetMedias()[index])) : QModelIndex();
	}

	//!
	//! Get the model previous index
	//!
	QModelIndex MediaModel::getPreviousModelIndex(const QModelIndex & index) const
	{
		if (index.isValid() == false || index.row() <= 0)
		{
			return QModelIndex();
		}
		return this->createIndex(index.row() - 1, 0, this->GetMedias()[index.row() - 1]);
	}

	//!
	//! Get the next model index
	//!
	QModelIndex MediaModel::getNextModelIndex(const QModelIndex & index) const
	{
		if (index.isValid() == false || index.row() >= this->GetMedias().size() - 1)
		{
			return QModelIndex();
		}
		return this->createIndex(index.row() + 1, 0, this->GetMedias()[index.row() + 1]);
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
		roles.insert(Qt::UserRole + 1,	"date");
		roles.insert(Qt::UserRole + 2,	"size");
		roles.insert(Qt::UserRole + 3,	"type");
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
			case Qt::UserRole + 1:	return media->GetDate();
			case Qt::UserRole + 2:	return media->GetSize();
			case Qt::UserRole + 3:	return static_cast< int >(media->GetType());
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

} // namespace MediaViewer