#ifndef __FOLDER_H__
#define __FOLDER_H__


namespace MediaViewer
{

	//!
	//! This class represents a folder.
	//!
	class Folder
		: public QObject
	{

		Q_OBJECT

		Q_PROPERTY(QString path READ GetPath WRITE SetPath NOTIFY pathChanged)
		Q_PROPERTY(QString name READ GetName NOTIFY nameChanged)
		Q_PROPERTY(int mediaCount READ GetMediaCount NOTIFY mediaCountChanged)

	signals:

		void pathChanged(const QString & path) const;
		void nameChanged(const QString & name) const;
		void mediaCountChanged(int mediaCount) const;

	public:

		Folder(const QString & path = "", const Folder * parent = nullptr);
		Folder(const Folder & other);
		~Folder(void);

		// public API
		const QString &					GetPath(void) const;
		const QString &					GetName(void) const;
		int								GetMediaCount(void) const;
		const Folder *					GetParent(void) const;
		const QVector< Folder * > &		GetChildren(void) const;

	private:

		// private API
		void	UpdateChildren(void) const;
		void	UpdateMedias(void) const;
		void	SetPath(const QString & path);

		//! The parent
		const Folder * m_Parent;

		//! The folder's path
		QString m_Path;

		//! The name of the folder
		QString m_Name;

		//! The number of medias
		mutable int m_MediaCount;

		//! True when the children's list is dirty
		mutable bool m_Dirty;

		//! The children
		mutable QVector< Folder * > m_Children;

	};

} // namespace MediaViewer


#endif // __FOLDER_H__
