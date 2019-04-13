#ifndef MODELS_MEDIA_MODEL_INL
#define MODELS_MEDIA_MODEL_INL


namespace MediaViewer
{

	//!
	//! Get the current root's path.
	//!
	inline const QString & MediaModel::GetRoot(void) const
	{
		return m_Root;
	}

	//!
	//! Get the sort type
	//!
	inline MediaModel::SortBy MediaModel::GetSortBy(void) const
	{
		return m_SortBy;
	}

	//!
	//! Get the sort direction
	//!
	inline MediaModel::SortOrder MediaModel::GetSortOrder(void) const
	{
		return m_SortOrder;
	}

}


#endif
