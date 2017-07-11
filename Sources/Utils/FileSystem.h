#ifndef __FILE_SYSTEM_H__
#define __FILE_SYSTEM_H__


//!
//! File system class used to manipulate file from QML.
//!
class FileSystem
	: public QObject
{

	Q_OBJECT

	Q_PROPERTY(bool canPaste READ CanPaste NOTIFY canPasteChanged)
	Q_PROPERTY(bool canTrash READ CanTrash NOTIFY canTrashChanged)

signals:

	void	canPasteChanged(bool value);
	void	canTrashChanged(bool value);

public:

	// constructor
	FileSystem(void);

	// QML API
	Q_INVOKABLE void	copy(QStringList files);
	Q_INVOKABLE void	cut(QStringList files);
	Q_INVOKABLE void	paste(QString destination);
	Q_INVOKABLE void	remove(QStringList files);

private:

	// private API
	bool	CanPaste(void) const;
	bool	CanTrash(void) const;
	void	InitTrashFolder(void);
	void	MoveToTrash(const QString & path);

	//! The list of copied files
	QStringList m_CopiedFiles;

	//! The list of cut files
	QStringList m_CutFiles;

	//! The trash folder
	QString m_TrashFolder;

};


#endif // __FILE_SYSTEM_H__
