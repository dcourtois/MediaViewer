#ifndef __MEDIA_MODEL_INL__
#define __MEDIA_MODEL_INL__


namespace MediaViewer
{

	//!
	//! Get the current root's path.
	//!
	const QString & MediaModel::GetRoot(void) const
	{
		return m_Root;
	}

	//!
	//! Get the sort type
	//!
	MediaModel::SortBy MediaModel::GetSortBy(void) const
	{
		return m_SortBy;
	}

	//!
	//! Get the sort direction
	//!
	MediaModel::SortOrder MediaModel::GetSortOrder(void) const
	{
		return m_SortOrder;
	}

} // namespace MediaViewer


#endif // __MEDIA_MODEL_INL__
