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
		, m_SortBy(SortBy::None)
		, m_SortOrder(SortOrder::Ascending)
	{
		// setup file watching
		QObject::connect(&m_FileWatcher, &QFileSystemWatcher::directoryChanged, [&] (const QString &) {
			this->beginResetModel();
			this->Clear();
			m_Dirty = true;
			this->GetMedias();
			this->endResetModel();
		});
	}

	//!
	//! Destructor.
	//!
	MediaModel::~MediaModel(void)
	{
		this->Clear();
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

		// remove the old path from the file watcher
		if (m_Root.isEmpty() == false)
		{
			m_FileWatcher.removePath(m_Root);
		}

		// reset the model
		this->beginResetModel();
		this->Clear();
		m_Root = path;
		this->endResetModel();

		// add the new path to the file watcher
		m_FileWatcher.addPath(m_Root);

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

			// sort
			this->Sort();

			// reset the dirty flag
			m_Dirty = false;
		}
		return m_Medias;
	}

	//!
	//! Set the sort type
	//!
	void MediaModel::SetSortBy(SortBy by)
	{
		if (m_SortBy != by)
		{
			this->sort(by, m_SortOrder);
			emit sortByChanged(by);
		}
	}

	//!
	//! Set the sort direction
	//!
	void MediaModel::SetSortOrder(SortOrder order)
	{
		if (m_SortOrder != order)
		{
			this->sort(m_SortBy, order);
			emit sortOrderChanged(order);
		}
	}

	//!
	//! Sort the model
	//!
	void MediaModel::Sort(void) const
	{
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

			case SortBy::None:
			default:
				break;
		}
	}

	//!
	//! The QML invokable sort method
	//!
	void MediaModel::sort(SortBy by, SortOrder order)
	{
		bool needSort = false;
		if (m_SortBy != by)
		{
			needSort = true;
			m_SortBy = by;
			emit sortByChanged(by);
		}
		if (m_SortOrder != order)
		{
			needSort = true;
			m_SortOrder = order;
			emit sortOrderChanged(order);
		}

		if (needSort == true)
		{
			this->beginResetModel();
			this->Sort();
			this->endResetModel();
		}
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
		Q_ASSERT(index.isValid() == true && index.row() >= 0 && index.row() < this->GetMedias().size());
		int newIndex = qMax(index.row() - 1, 0);
		return this->createIndex(newIndex, 0, this->GetMedias()[newIndex]);
	}

	//!
	//! Get the next model index
	//!
	QModelIndex MediaModel::getNextModelIndex(const QModelIndex & index) const
	{
		Q_ASSERT(index.isValid() == true && index.row() >= 0 && index.row() < this->GetMedias().size());
		int newIndex = qMin(index.row() + 1, this->GetMedias().size() - 1);
		return this->createIndex(newIndex, 0, this->GetMedias()[newIndex]);
	}

	//!
	//! Get the last model index
	//!
	QModelIndex MediaModel::getLastModelIndex(void) const
	{
		return this->getModelIndexByIndex(this->GetMedias().size() - 1);
	}

	//!
	//! Get a model index from an index
	//!
	QModelIndex MediaModel::getModelIndexByIndex(int index) const
	{
		return (index >= 0 && index < this->GetMedias().size()) ? this->createIndex(index, 0, this->GetMedias()[index]) : QModelIndex();
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
		return {
			{ Qt::DisplayRole,	"name" },
			{ Qt::UserRole,		"path" },
			{ Qt::UserRole + 1,	"date" },
			{ Qt::UserRole + 2,	"size" },
			{ Qt::UserRole + 3,	"type" }
		};
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
			case Qt::UserRole + 2:	return static_cast< qulonglong >(media->GetSize());
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
