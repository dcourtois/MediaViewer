#include "MediaViewerPCH.h"
#include "Memory.h"


#if !defined(RETAIL)


#include <unordered_map>
#include <iostream>
#include <sstream>
#include <mutex>
#include <cstdio>


//!
//! Allocator used with our hash map to avoid recursive locks
//!
template< class T >
struct Allocator
{
	//!
	//! Value of the allocated objects (required)
	//!
	typedef T value_type;

	//!
	//! Default constructor (required)
	//!
	Allocator(void)
	{
	}

	//!
	//! Copy (?) constructor (required)
	//!
	template< class U > Allocator(const Allocator< U > &)
	{
	}

	//!
	//! Allocate a few objects.
	//!
	//! @param num
	//!		The number of object to allocate memory for.
	//!
	inline T * allocate(std::size_t num)
	{
		return reinterpret_cast< T * >(malloc(num * sizeof(T)));
	}

	//!
	//! De-allocate memory.
	//!
	inline void deallocate(T * pointer, std::size_t)
	{
		free(pointer);
	}
};

template< class T, class U > bool operator == (const Allocator< T > &, const Allocator< U > &) { return false; }
template< class T, class U > bool operator != (const Allocator< T > &, const Allocator< U > &) { return true; }

//!
//! Mutex used to protect AllocatedBlocks access.
//!
std::mutex Mutex;

//!
//! Define our custom hash map (using a malloc/free allocator to avoid recursive new)
//!
typedef std::unordered_map<
	void *,
	std::tuple< size_t, const char *, int >,
	std::hash< void * >,
	std::equal_to< void * >,
	Allocator< std::pair< void *, std::tuple< size_t, const char *, int > > >
> AllocatedBlockMap;

//!
//! Static hash map used to get allocated blocks informations.
//!
//! @note
//!		This is dynamically allocated, because first allocations can occur during static variable
//!		initialization time, and if it's the case, we would have no way to ensure AllocatedBlocks
//!		is already initalized at that point. Thus the dynamic allocation and the call to
//!		CheckAllocatedBlock before each operation.
//!
static AllocatedBlockMap * AllocatedBlocks = nullptr;

//!
//! Allocate the allocated blocks informations map if needed.
//!
void CheckAllocatedBlocks(void)
{
	std::lock_guard< std::mutex > lock(Mutex);
	if (AllocatedBlocks == nullptr)
	{
		void * pointer = malloc(sizeof(AllocatedBlockMap));
		AllocatedBlocks = new (pointer) AllocatedBlockMap ();
	}
}

//!
//! Dumps the memory report.
//!
//! @note
//!		Do not use anything that might use a new or delete operator (std::string, std::stringstream, etc.)
//!		because this function is called upon static variables destruction, and we don't want to call our
//!		overriden operators at that moment (that would screw the AllocatedBlocks which are being iterated over) 
//!
void DumpMemory(void)
{
	if (AllocatedBlocks == nullptr)
	{
		return;
	}
	qDebug() << "";
	if (AllocatedBlocks->empty() == true)
	{
		qDebug() << "Congratulations, no memory leak !";
	}
	else
	{
		char line[1024];
		auto blocks = AllocatedBlocks;
		sprintf(line, "Memory leak detected - %d block%s still allocated :", blocks->size(), blocks->size() > 1 ? "s" : "");
		qDebug() << line;
		for (auto entry : *AllocatedBlocks)
		{
			sprintf(
				line,
				"%s(%d): %d bytes at location 0x%x",
				std::get< 1 >(entry.second),
				std::get< 2 >(entry.second),
				std::get< 0 >(entry.second),
				entry.first
			);
			qDebug() << line;
		}
	}
	qDebug() << "";
}


//!
//! Override of new
//!
void * operator new(size_t size, const char * filename, int line)
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	void * pointer = malloc(size);
	AllocatedBlocks->insert(std::make_pair(pointer, std::make_tuple(size, filename, line)));
	return pointer;
};

//!
//! Override of new []
//!
void * operator new [](size_t size, const char * filename, int line)
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	void * pointer = malloc(size);
	AllocatedBlocks->insert(std::make_pair(pointer, std::make_tuple(size, filename, line)));
	return pointer;
};

//!
//! Override of delete
//!
void operator delete(void * pointer) noexcept
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	auto entry = AllocatedBlocks->find(pointer);
	if (entry != AllocatedBlocks->end())
	{
		AllocatedBlocks->erase(entry);
	}
	free(pointer);
}

//!
//! Override of delete
//!
void operator delete(void * pointer, const char * /* filename */, int /* line */)
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	auto entry = AllocatedBlocks->find(pointer);
	if (entry != AllocatedBlocks->end())
	{
		AllocatedBlocks->erase(entry);
	}
	free(pointer);
}

//!
//! Override of delete []
//!
void operator delete [](void * pointer) noexcept
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	auto entry = AllocatedBlocks->find(pointer);
	if (entry != AllocatedBlocks->end())
	{
		AllocatedBlocks->erase(entry);
	}
	free(pointer);
}

//!
//! Override of delete
//!
void operator delete [](void * pointer, const char * /* filename */, int /* line */)
{
	CheckAllocatedBlocks();
	std::lock_guard< std::mutex > lock(Mutex);
	auto entry = AllocatedBlocks->find(pointer);
	if (entry != AllocatedBlocks->end())
	{
		AllocatedBlocks->erase(entry);
	}
	free(pointer);
}


namespace
{
	//!
	//! Struct that will dump the content of the memory manager upon destruction.
	//!
	struct AutoDump
	{
		//!
		//! Destructor.
		//!
		~AutoDump(void)
		{
			DumpMemory();

			// don't forget to cleanup AllocatedBlocks
			free(AllocatedBlocks);
			AllocatedBlocks = nullptr;
		}
	};

	//!
	//! This instance will be destroyed upon program termination, resulting in a memory dump.
	//!
	AutoDump autoDump;

}


#endif
