#ifndef __MEDIA_H__
#define __MEDIA_H__


namespace MediaViewer
{

	//!
	//! This class represents a media file.
	//!
	class Media
		: public QObject
	{

		Q_OBJECT

		Q_ENUMS(Type)
		Q_PROPERTY(QString path READ GetPath NOTIFY pathChanged)
		Q_PROPERTY(QString name READ GetName NOTIFY nameChanged)
		Q_PROPERTY(QDateTime date READ GetDate NOTIFY dateChanged)
		Q_PROPERTY(uint64_t size READ GetSize NOTIFY sizeChanged)
		Q_PROPERTY(Type type READ GetType NOTIFY typeChanged)

	public:

		//!
		//! The different type of media
		//!
		enum class Type
		{
			//! A simple static image
			Image = 0,

			//! An animated image
			AnimatedImage,

			//! A movie
			Movie,

			//! Not a media
			NotSupported,
		};

	signals:

		void	pathChanged(const QString & path);
		void	nameChanged(const QString & name);
		void	dateChanged(const QDate & date);
		void	sizeChanged(uint64_t size);
		void	typeChanged(Type type);

	public:

		Media(const QString & path = "");
		Media(const Media & other);
		~Media(void);

		// public API
		const QString &		GetPath(void) const;
		const QString &		GetName(void) const;
		const QDateTime &	GetDate(void) const;
		uint64_t			GetSize(void) const;
		Type				GetType(void) const;

		// utilities
		static bool		IsMedia(const QString & filename);
		static Type		GetType(const QString & filename);

	private:

		//! The media path
		QString m_Path;

		//! The media name
		QString m_Name;

		//! The media date
		QDateTime m_Date;

		//! The size of the media in bytes
		uint64_t m_Size;

		//! The media type
		Type m_Type;

	};

} // namespace MediaViewer


#endif // __MEDIA_H__
