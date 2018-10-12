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
			// TODO: scan for new/deleted folders
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
			MT_DELETE folder;
		}
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
					m_Children.push_back(MT_NEW Folder(dir.absoluteFilePath(child.filePath()), this));
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
		MT_NEW Job([&] (void) {
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
