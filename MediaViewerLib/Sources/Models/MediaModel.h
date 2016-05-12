#ifndef __MEDIA_MODEL_H__
#define __MEDIA_MODEL_H__


namespace MediaViewerLib
{
	class Media;
}


// This is needed to remove the C4251 warning
// See : http://support.microsoft.com/kb/168958/en-us
// Also note that it must be declared before the actual use.
MEDIA_VIEWER_LIB_IMPORT_TEMPLATE template class MEDIA_VIEWER_LIB_EXPORT QVector< MediaViewerLib::Media * >;


namespace MediaViewerLib
{

	//!
	//! Model used to represent a folder hierarchy
	//!
	class MEDIA_VIEWER_LIB_EXPORT MediaModel
		: public QAbstractItemModel
	{

		Q_OBJECT

		Q_PROPERTY(QString root READ GetRoot WRITE SetRoot NOTIFY rootChanged)

	signals:

		void	rootChanged(const QString & path);

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

		// public QML API
		Q_INVOKABLE int				getIndexByPath(const QString & path) const;
		Q_INVOKABLE QModelIndex		getModelIndexByPath(const QString & path) const;
		Q_INVOKABLE QModelIndex		getPreviousModelIndex(const QModelIndex & index) const;
		Q_INVOKABLE QModelIndex		getNextModelIndex(const QModelIndex & index) const;
		Q_INVOKABLE Media *			getMedia(const QModelIndex & index) const;
		Q_INVOKABLE int				getIndex(const QModelIndex & index) const;

	private:

		void	Clear(void);

		//! The root folder
		QString m_Root;

		//! Dirty flag
		mutable bool m_Dirty;

		//! The media in the root folder
		mutable QVector< Media * > m_Medias;

	};

} // namespace MediaViewerLib


#endif // __MEDIA_MODEL_H__
