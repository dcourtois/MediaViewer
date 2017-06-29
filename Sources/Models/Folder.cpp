#include "MediaViewerPCH.h"
#include "FolderModel.h"
#include "Folder.h"
#include "Media.h"
#include "Utils/Job.h"


namespace MediaViewer
{

	//!
	//! Constructor.
	//!
	Folder::Folder(const QString & path, const Folder * parent)
		: m_Parent(parent)
		, m_MediaCount(0)
		, m_Dirty(true)
	{
		this->SetPath(path);

		// setup the file watcher
		QObject::connect(&m_FileWatcher, &QFileSystemWatcher::directoryChanged, [&] (const QString &) {
			this->UpdateMedias();
		});

	}

	//!
	//! Copy constructor
	//!
	Folder::Folder(const Folder & other)
		: QObject(nullptr)
		, m_Parent(other.m_Parent)
		, m_MediaCount(0)
		, m_Dirty(true)
	{
		this->SetPath(other.m_Path);
	}

	//!
	//! Destructor.
	//!
	Folder::~Folder()
	{
		for (Folder * folder : m_Children)
		{
			DELETE folder;
		}
	}

	//!
	//! Get the folder's path
	//!
	const QString & Folder::GetPath(void) const
	{
		return m_Path;
	}

	//!
	//! Set the folder's path
	//!
	void Folder::SetPath(const QString & path)
	{
		if (m_Path != path)
		{
			// remove old path
			if (m_Path.isEmpty() == false)
			{
				m_FileWatcher.removePath(m_Path);
			}

			// update
			m_Path = path;
			m_Dirty = true;

			// add new path
			if (path.isEmpty() == false)
			{
				m_FileWatcher.addPath(path);
			}

			// get the name
			QDir dir = QDir(path);
			m_Name = dir.dirName();

			// drive letters
			if (m_Name.isEmpty() == true)
			{
				m_Name = dir.absolutePath();
			}

			// notify
			emit pathChanged(m_Path);
			emit nameChanged(m_Name);

			// update the medias
			this->UpdateMedias();
		}
	}

	//!
	//! Get the folder's name
	//!
	const QString & Folder::GetName(void) const
	{
		return m_Name;
	}

	//!
	//! Get the number of medias in this folder
	//!
	int Folder::GetMediaCount(void) const
	{
		return m_MediaCount;
	}

	//!
	//! Get the folder's parent
	//!
	const Folder * Folder::GetParent(void) const
	{
		return m_Parent;
	}

	//!
	//! Get the children
	//!
	const QVector< Folder * > & Folder::GetChildren(void) const
	{
		this->UpdateChildren();
		return m_Children;
	}

	//!
	//! Update the children list
	//!
	void Folder::UpdateChildren(void) const
	{
		if (m_Dirty == true)
		{
			// initialize the list of children
			QDir dir(m_Path);
			if (dir.exists() == true)
			{
				for (const auto & child : dir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name))
				{
					m_Children.push_back(NEW Folder(dir.absoluteFilePath(child.filePath()), this));
				}
			}

			// reset dirty flag
			m_Dirty = false;
		}
	}

	//!
	//! Update the medias list for the folder
	//!
	void Folder::UpdateMedias(void) const
	{
		NEW Job([&] (void) {
			// reset the media count
			m_MediaCount = 0;

			// initialize the list of children, and count medias
			QDir dir(m_Path);
			if (dir.exists() == true)
			{
				for (const auto & child : dir.entryInfoList(QDir::Files, QDir::NoSort))
				{
					if (Media::IsMedia(child.fileName()))
					{
						++m_MediaCount;
					}
				}
			}

			// notify
			emit mediaCountChanged(m_MediaCount);
		});
	}

} // namespace MediaViewer
