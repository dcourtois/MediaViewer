#include "FileSystem.h"

#include "CppUtils/MemoryTracker.h"
#include "QtUtils/Settings.h"

#if defined(WINDOWS)
#	include <windows.h>
#	include <shellapi.h>
#endif

#include <QDebug>
#include <QFileInfo>



//!
//! Constructor
//!
FileSystem::FileSystem(void)
{
}

//!
//! Copy the files
//!
void FileSystem::copy(QStringList files)
{
	m_CopiedFiles = files;
	m_CutFiles.clear();
	emit canPasteChanged(this->CanPaste());
}

//!
//! Cut the files
//!
void FileSystem::cut(QStringList files)
{
	m_CutFiles = files;
	m_CopiedFiles.clear();
	emit canPasteChanged(this->CanPaste());
}

//!
//! Paste the files
//!
void FileSystem::paste(QString destination)
{
	for (const QString & filename : m_CopiedFiles)
	{
		QFileInfo info(filename);
		if (info.exists() == true)
		{
			QFile file(filename);
			file.copy(destination + "/" + info.fileName());
		}
	}

	for (const QString & filename : m_CutFiles)
	{
		QFileInfo info(filename);
		if (info.exists() == true)
		{
			QFile file(filename);
			file.copy(destination + "/" + info.fileName());
			file.remove();
		}
	}

	m_CopiedFiles.clear();
	m_CutFiles.clear();
	emit canPasteChanged(false);
}

//!
//! Erase the files
//!
void FileSystem::remove(QStringList paths)
{
	// check if we need to permanently delete
	bool permanent = Settings::Get< bool >("FileSystem.DeletePermanently");
	for (const QString & path : paths)
	{
		if (permanent == true)
		{
			QFile file(path);
			if (file.remove() == false)
			{
				qDebug() << "failed removing file " << file << " with error " << file.errorString();
			}
		}
		else
		{
			this->MoveToTrash(path);
		}
	}
}

//!
//! Check if the system has files to paste
//!
bool FileSystem::CanPaste(void) const
{
	return m_CopiedFiles.empty() == false || m_CutFiles.empty() == false;
}

//!
//! Send a file to trash
//!
void FileSystem::MoveToTrash(const QString & path)
{
	QFile(path).moveToTrash();
}
