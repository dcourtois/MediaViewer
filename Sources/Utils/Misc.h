#ifndef __UTILS_MISC_H__
#define	__UTILS_MISC_H__


namespace MediaViewer
{
	namespace Utils
	{

		template< typename ContainerType, typename Type >		int		IndexOf(const ContainerType & container, const Type & element);
		template< typename ContainerType, typename Functor >	void	Sort(ContainerType & container, const Functor & functor);

	} // namespace Utils
} // namespace MediaViewer


#include "Misc.inl"


#endif // __UTILS_MISC_H__
