#ifndef __UTILS_MISC_INL__
#define	__UTILS_MISC_INL__


namespace MediaViewerLib
{
	namespace Utils
	{

		//!
		//! Get the index of an element in a container.
		//!
		//! @param container
		//!		The container.
		//!
		//! @param element
		//!		The element.
		//!
		//! @return
		//!		The 0 based index of the element in the list if found, -1 otherwise.
		//!
		template< typename ContainerType, typename Type >
		int IndexOf(const ContainerType & container, const Type & element)
		{
			auto iterator = std::find(container.begin(), container.end(), element);
			return iterator == container.end() ? -1 : int(std::distance(container.begin(), iterator));
		}

		//!
		//! Sort a container using a functor.
		//!
		//! @param container
		//!		The container.
		//!
		//! @param functor
		//!		The functor. Can be a lambda, std::function, etc.
		//!
		template< typename ContainerType, typename Functor >
		void Sort(ContainerType & container, const Functor & functor)
		{
			std::sort(container.begin(), container.end(), functor);
		}

	} // namespace Utils
} // namespace MediaViewerLib


#endif // __UTILS_MISC_INL__
