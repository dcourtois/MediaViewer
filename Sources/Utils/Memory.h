#ifndef __UTILS_MEMORY_H__
#define	__UTILS_MEMORY_H__


//!
//! @file Memory.h
//!
//! This file contains helper macros used to track allocated memory.
//!
//! By default, memory allocations are tracked and reported only in
//! debug. You can override this behavior by simply defining the
//! @a MEMORY_CHECK macro.
//!

//!
//! @a MEMORY_CHECK
//!
//! By default, memory tracking and leak reporting is only done in
//! debug. Set this macro to 1 to always activate this, or to 0 to
//! always disable it.
//!
#if !defined(MEMORY_CHECK)
#	if (QT_NO_DEBUG)
#		define MEMORY_CHECK 0
#	else
#		define MEMORY_CHECK 1
#	endif
#endif


#if MEMORY_CHECK == 1

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
