#ifndef __MEDIA_MODEL_H__
#define __MEDIA_MODEL_H__


namespace MediaViewer
{

	class Media;


	//!
	//! Model used to represent a folder hierarchy
	//!
	class MediaModel
		: public QAbstractItemModel
	{

		Q_OBJECT

		Q_ENUMS(SortBy)
		Q_ENUMS(SortOrder)
		Q_PROPERTY(QString root READ GetRoot WRITE SetRoot NOTIFY rootChanged)
		Q_PROPERTY(SortBy sortBy READ GetSortBy WRITE SetSortBy NOTIFY sortByChanged)
		Q_PROPERTY(SortOrder sortOrder READ GetSortOrder WRITE SetSortOrder NOTIFY sortOrderChanged)

	public:

		//! The various sort options
		enum class SortBy
		{
			Name = 0,
			Size,
			Date,
			Type
		};

		//! The sort order
		enum class SortOrder
		{
			Ascending = 0,
			Descending,
		};

	signals:

		void	rootChanged(const QString & path);
		void	sortByChanged(SortBy sortBy);
		void	sortOrderChanged(SortOrder sortOrder);

	public:

		MediaModel(QObject * parent = nullptr);
		~MediaModel(void);

		// QAbstractItemModel implementation
		QHash< int, QByteArray >	roleNames(void) const final;
		QVariant					data(const QModelIndex & index, int role = Qt::DisplayRole) const final;
		QModelIndex					index(int row, int column, const QModelIndex & parent = QModelIndex()) const final;
		QModelIndex					parent(const QModelIndex & index) const final;
		int							rowCount(const QModelIndex & parent = QModelIndex()) const final;
		int							columnCount(const QModelIndex & parent = QModelIndex()) const final;

		// public API
		const QString &				GetRoot(void) const;
		void						SetRoot(const QString & path);
		const QVector< Media * > &	GetMedias(void) const;
		SortBy						GetSortBy(void) const;
		void						SetSortBy(SortBy by);
		SortOrder					GetSortOrder(void) const;
		void						SetSortOrder(SortOrder order);
		void						Sort(void);

		// public QML API
		Q_INVOKABLE int				getIndexByPath(const QString & path) const;
		Q_INVOKABLE QModelIndex		getModelIndexByPath(const QString & path) const;
		Q_INVOKABLE QModelIndex		getPreviousModelIndex(const QModelIndex & index) const;
		Q_INVOKABLE QModelIndex		getNextModelIndex(const QModelIndex & index) const;
		Q_INVOKABLE Media *			getMedia(const QModelIndex & index) const;
		Q_INVOKABLE int				getIndex(const QModelIndex & index) const;
		Q_INVOKABLE void			sort(void);

	private:

		void	Clear(void);

		//! The root folder
		QString m_Root;

		//! Dirty flag
		mutable bool m_Dirty;

		//! The media in the root folder
		mutable QVector< Media * > m_Medias;

		//! The sort criteria
		SortBy m_SortBy;

		//! The sort order
		SortOrder m_SortOrder;

	};

} // namespace MediaViewer


#endif // __MEDIA_MODEL_H__