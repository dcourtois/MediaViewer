#pragma once

#include <QObject>


//!
//! File system class used to manipulate file from QML.
//!
class FileSystem
	: public QObject
{

	Q_OBJECT

	Q_PROPERTY(bool canPaste READ CanPaste NOTIFY canPasteChanged)

signals:

	void	canPasteChanged(bool value);

public:

	// constructor
	FileSystem(void);

	// QML API
	Q_INVOKABLE void	copy(QStringList paths);
	Q_INVOKABLE void	cut(QStringList paths);
	Q_INVOKABLE void	paste(QString destination);
	Q_INVOKABLE void	remove(QStringList paths);

private:

	// private API
	bool	CanPaste(void) const;
	void	InitTrashFolder(void);
	void	MoveToTrash(const QString & path);

	//! The list of copied files
	QStringList m_CopiedFiles;

	//! The list of cut files
	QStringList m_CutFiles;

};
