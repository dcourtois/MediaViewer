#ifndef __UTILS_MEMORY_H__
#define	__UTILS_MEMORY_H__


//!
//! @file Memory.h
//!
//! This file contains helper macros used to track allocated memory.
//!

#if !defined(RETAIL)

extern void * operator new(size_t size, const char * filename, int line);
extern void * operator new [] (size_t size, const char * filename, int line);
extern void operator delete(void * pointer) noexcept;
extern void operator delete(void * pointer, const char * filename, int line);
extern void operator delete [] (void * pointer) noexcept;
extern void operator delete [] (void * pointer, const char * filename, int line);

#	define	NEW				new(__FILE__, __LINE__)
#	define	NEW_ARRAY		new [](__FILE__, __LINE__)
#	define	DELETE			delete
#	define	DELETE_ARRAY	delete []

#else

#	define	NEW				new
#	define	NEW_ARRAY		new []
#	define	DELETE			delete
#	define	DELETE_ARRAY	delete []

#endif


#endif // __UTILS_MEMORY_H__
