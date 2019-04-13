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
cu_option (QT_DIR "C:/Development/Libs/Qt/5.12.2/msvc2017_64/lib/cmake")

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
		Test
	REQUIRED
)

#
# Auto moc and rcc
#
set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTORCC ON)
set (CMAKE_AUTOMOC_MOC_OPTIONS "-bMediaViewerPCH.h")

#
# The library
#
add_executable (MediaViewer
	# application and resources
	Sources/Application/Application.qrc
	Resources/Resources.qrc

	# image providers
	Sources/ImageProviders/FolderIconProvider.cpp
	Sources/ImageProviders/FolderIconProvider.h
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
)

#
# Using PCH to speed-up compilation
#
target_pch (MediaViewer
	MediaViewerPCH.h
	Sources/MediaViewerPCH.cpp
)

#
# compiler's requirements
#
target_compile_features (MediaViewer
	PUBLIC
		cxx_std_17
)

#
# includes
#
target_include_directories (MediaViewer
	PUBLIC
		Sources
		Libs
)

#
# libs
#
target_link_libraries(MediaViewer
	PUBLIC
		Qt5::Core
		Qt5::Multimedia
		Qt5::Qml
		Qt5::Quick
		Qt5::QuickControls2
		Qt5::Sql
		Qt5::Svg
)

#
# Compile definitions
#
target_compile_definitions (MediaViewer
	PUBLIC
		# Enable memory tracking
		MEMORY_CHECK=1

		# Platforms
		$<$<PLATFORM_ID:Windows>:WINDOWS>

		# Compilers
		$<$<CXX_COMPILER_ID:MSVC>:MSVC>
		$<$<CXX_COMPILER_ID:Clang>:CLANG>

		# MSVC
		$<$<CXX_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>

		# QML debug
		$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)

#
# Compile options
#
target_compile_options (MediaViewer
	PUBLIC
		# MSVC
		$<$<CXX_COMPILER_ID:MSVC>:/W4>

		# Clang
		$<$<CXX_COMPILER_ID:Clang>:-Wall>
)
