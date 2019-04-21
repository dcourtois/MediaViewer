#
# Min version of CMake
#
cmake_minimum_required(VERSION 3.8)

#
# Project
#
project(MediaViewer)

#
# Include our utility scripts
#
include (CMakeUtils.cmake)

#
# Define options for this project
#
cu_option (QT_DIR "C:/Development/Libs/Qt/5.12.3/msvc2017_64/lib/cmake")

#
# Configure Qt
#
set (CMAKE_PREFIX_PATH ${QT_DIR})
find_package (Qt5 5.12
	COMPONENTS
		Multimedia
		Qml
		Quick
		QuickControls2
		Sql
		Svg
	REQUIRED
)

#
# Auto moc and rcc
#
set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTORCC ON)
set (CMAKE_AUTOMOC_MOC_OPTIONS "-bMediaViewerPCH.h")

#
# Add QtUtils
#
add_subdirectory (Libs/QtUtils)

#
# The library
#
add_executable (MediaViewer WIN32
	# application and resources
	Sources/Application/Application.qrc
	Resources/Resources.qrc

	# image providers
	Sources/ImageProviders/FolderIconProvider.cpp
	Sources/ImageProviders/FolderIconProvider.h
	Sources/ImageProviders/ImageResponse.cpp
	Sources/ImageProviders/ImageResponse.h
	Sources/ImageProviders/MediaPreviewProvider.cpp
	Sources/ImageProviders/MediaPreviewProvider.h

	# models
	Sources/Models/Folder.cpp
	Sources/Models/Folder.h
	Sources/Models/Folder.inl
	Sources/Models/FolderModel.cpp
	Sources/Models/FolderModel.h
	Sources/Models/FolderModel.inl
	Sources/Models/Media.cpp
	Sources/Models/Media.h
	Sources/Models/Media.inl
	Sources/Models/MediaModel.cpp
	Sources/Models/MediaModel.h
	Sources/Models/MediaModel.inl

	# utilities
	Sources/Utils/Cursor.cpp
	Sources/Utils/Cursor.h
	Sources/Utils/FileSystem.cpp
	Sources/Utils/FileSystem.h
	Sources/Utils/Job.cpp
	Sources/Utils/Job.h

	# main stuff
	Sources/Main.cpp
	Sources/MediaViewerPCH.cpp
	Sources/MediaViewerPCH.h
	Sources/RegisterQMLTypes.cpp
	Sources/RegisterQMLTypes.h

	# RC file on Windows
	$<$<PLATFORM_ID:Windows>:Resources/MediaViewer.rc>
)

#
# Using PCH to speed-up compilation
#
target_pch (MediaViewer
	MediaViewerPCH.h
	Sources/MediaViewerPCH.cpp
)

#
# includes
#
target_include_directories (MediaViewer
	PRIVATE
		Sources
		Libs
)

#
# libs
#
target_link_libraries(MediaViewer
	PRIVATE
		Qt5::Core
		Qt5::Multimedia
		Qt5::Qml
		Qt5::QuickControls2
		Qt5::Sql
		Qt5::Svg
		QtUtils
)

#
# Compile definitions
#
target_compile_definitions (MediaViewer
	PRIVATE
		# Debug stuff
		$<$<NOT:$<CONFIG:Release>>:MEMORY_CHECK=1>
		$<$<NOT:$<CONFIG:Release>>:QT_QML_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_INFO_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_WARNING_OUTPUT>

		# Platforms
		$<$<PLATFORM_ID:Windows>:WINDOWS>
		$<$<PLATFORM_ID:Linux>:LINUX>
		$<$<PLATFORM_ID:Darwin>:MACOS>

		# Compilers
		$<$<CXX_COMPILER_ID:MSVC>:MSVC>
		$<$<CXX_COMPILER_ID:Clang>:CLANG>
		$<$<CXX_COMPILER_ID:GNU>:GCC>

		# Disable some annoying warnings
		$<$<CXX_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
)

#
# Compile options
#
target_compile_options (MediaViewer
	PRIVATE
		# Warning levels
		$<$<CXX_COMPILER_ID:MSVC>:/W4 /WX>
		$<$<CXX_COMPILER_ID:Clang>:-Wall -Werror>
		$<$<CXX_COMPILER_ID:GNU>:-Wall -Werror>
)
