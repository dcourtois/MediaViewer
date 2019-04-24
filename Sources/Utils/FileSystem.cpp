#include "MediaViewerPCH.h"
#include "FileSystem.h"


//!
//! Constructor
//!
FileSystem::FileSystem(void)
{
	this->InitTrashFolder();
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
	bool permanent = Settings::Get< bool >("FileSystem.DeletePermanently") || this->CanTrash() == false;
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
//! Check if the system can move things to trash
//!
bool FileSystem::CanTrash(void) const
{
#if defined(LINUX)
	return m_TrashFolder.isEmpty() == false;
#elif defined(WINDOWS)
	return false;
#else
	static_assert(false, "implement FileSystem::CanTrash for your platform");
#endif
}

//!
//! Initialize the trash folder
//!
void FileSystem::InitTrashFolder(void)
{
#if defined(LINUX)
	// note: following https://specifications.freedesktop.org/trash-spec/trashspec-latest.html
	QVector< QString > trashes = {
		QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/.local/share/Trash",
		QStandardPaths::writableLocation(QStandardPaths::HomeLocation) + "/.trash"
	};
	for (const QString & trash : trashes)
	{
		if (QDir(trash).exists() == true ||
			QDir(trash + "/info").exists() == true ||
			QDir(trash + "/files").exists() == true)
		{
			m_TrashFolder = trash;
			emit canTrashChanged(true);
			break;
		}
	}
#elif defined(WINDOWS)
#else
	static_assert(false, "implement FileSystem::InitTrash for your platform");
#endif
}

//!
//! Send a file to trash
//!
void FileSystem::MoveToTrash(const QString & path)
{
#if defined(LINUX)
	// note: following https://specifications.freedesktop.org/trash-spec/trashspec-latest.html
	// check that we can trash
	if (m_TrashFolder.isEmpty() == true)
	{
		return;
	}

	// get a unique trash name
	QString trashName = path.section('/', -1, -1);
	int trashIndex = 0;
	QString trashSuffix = ".trash000000";
	while (QFile::exists(m_TrashFolder + "/files/" + trashName + trashSuffix) == true)
	{
		++trashIndex;
		trashSuffix = QString(".trash%1").arg(trashIndex, 6, 10, QLatin1Char('0'));
	}
	trashName = trashName + trashSuffix;

	// create the content of the file info
	QString trashInfo = "[Trash Info]\n";
	trashInfo += "Path=" + path + "\n";
	trashInfo += "DeletionDate=" + QDateTime::currentDateTime().toString("YYYY-MM-DDThh:mm:ss") + "\n";

	// move file
	QFile file(path);
	file.copy(m_TrashFolder + "/files/" + trashName);
	file.remove();

	// create info
	QFile info(m_TrashFolder + "/info/" + trashName + ".trashinfo");
	info.open(QIODevice::WriteOnly);
	info.write(trashInfo.toUtf8());
#elif defined(WINDOWS)
	Q_UNUSED(path);
#else
	static_assert(false, "implement FileSystem::MoveToTrash for your platform");
#endif
}
