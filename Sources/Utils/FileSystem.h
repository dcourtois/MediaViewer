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

signals:

	void	canPasteChanged(bool value);

public:

	// QML API
	Q_INVOKABLE void	copy(QStringList files);
	Q_INVOKABLE void	cut(QStringList files);
	Q_INVOKABLE void	paste(QString destination);
	Q_INVOKABLE void	remove(QStringList files);

private:

	// private API
	bool CanPaste(void) const;

	//! The list of copied files
	QStringList m_CopiedFiles;

	//! The list of cut files
	QStringList m_CutFiles;

};


#endif // __FILE_SYSTEM_H__
