#
# Min version of CMake
#
cmake_minimum_required (VERSION 3.16)

#
# Project
#
project (MediaViewer
	VERSION 0.1.0
	LANGUAGES CXX
	DESCRIPTION "Multiplatform image viewer."
)

#
# Expose a few options to configure various things
#
option (WARNINGS_AS_ERRORS "If ON, warnings will be treated as errors during compilation. \
This is the default, but you can set that to OFF if you're using a compiler which I haven't \
tested and on which the project generates warnings." ON)
option (USE_PRECOMPILED_HEADERS "ON by default. When using CMake version 3.16 or greater, \
uses precompiled header to speed up compilation time." ON)

#
# Setup CMake, Qt, load our utilities, etc.
#
include (CMake/Setup.cmake)
include (CMake/CMakeUtils/Qt.cmake)
include (CMake/CMakeUtils/Utils.cmake)

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
	Sources/RegisterQMLTypes.cpp
	Sources/RegisterQMLTypes.h
)

#
# Application icon
#
target_set_app_icon (MediaViewer
	"Resources/Icons/MediaViewer.ico"
)

#
# Set the precompiled headers
# Note that target_precompile_headers use the same compilation options as the target they are
# added to. So, if any of the header you include in your pch generates any warning and you have
# the poor taste or compiling warning as error, you have no way of making your pch build -_-
# The only trick I found was to generate headers that are added before and after all the pch's
# headers. In the first I disable all warnings using pragmas, in the second I re-enable them.
#
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.16" AND USE_PRECOMPILED_HEADERS)
	if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/pch_begin.h")
		file (WRITE ${CMAKE_CURRENT_BINARY_DIR}/pch_begin.h "
			#if defined(WINDOWS)
			#	pragma warning ( push , 0 )
			#endif
		")
	endif ()
	if (NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/pch_end.h")
		file (WRITE ${CMAKE_CURRENT_BINARY_DIR}/pch_end.h "
			#if defined(WINDOWS)
			#	pragma warning ( pop )
			#endif
		")
	endif ()
	target_precompile_headers (MediaViewer
		PRIVATE
			# header guard
			"${CMAKE_CURRENT_BINARY_DIR}/pch_begin.h"
			# Qt
			<QAbstractVideoSurface>
			<QApplication>
			<QCommandLineParser>
			<QDebug>
			<QDir>
			<QFile>
			<QFileIconProvider>
			<QFileInfo>
			<QFileSystemWatcher>
			<QIcon>
			<QImage>
			<QImageReader>
			<QList>
			<QMediaPlayer>
			<QObject>
			<QPainter>
			<QPixmap>
			<QQmlApplicationEngine>
			<QQmlContext>
			<QQmlExtensionPlugin>
			<QQuickImageProvider>
			<QQuickStyle>
			<QRunnable>
			<QSize>
			<QString>
			<QtDebug>
			<QtQml>
			<QVector>
			<QWidget>
			# STL
			<algorithm>
			<atomic>
			<cctype>
			<functional>
			<thread>
			# Platform stuff
			$<$<PLATFORM_ID:Windows>:<Windows.h>>
			# header guard
			"${CMAKE_CURRENT_BINARY_DIR}/pch_end.h"
			# Our own utililities
			"Libs/CppUtils/MemoryTracker.h"
			"Libs/CppUtils/STLUtils.h"
			"Libs/QtUtils/Settings.h"
			"Libs/QtUtils/Utils.h"
	)
endif ()

#
# c++17
#
target_compile_features (MediaViewer
	PRIVATE
		cxx_std_17
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
		QtUtils
)

#
# Compile definitions
#
target_compile_definitions (MediaViewer
	PRIVATE
		# Application identification
		ORGANIZATION_NAME="Citron"
		APPLICATION_NAME="${CMAKE_PROJECT_NAME}$<$<CONFIG:Debug>:Debug>"
		APPLICATION_VERSION="${CMAKE_PROJECT_VERSION}"

		# Debug stuff
		$<$<NOT:$<CONFIG:Release>>:MEMORY_CHECK=1>
		$<$<NOT:$<CONFIG:Release>>:QT_QML_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG>
		$<$<CONFIG:Release>:QT_NO_DEBUG_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_INFO_OUTPUT>
		$<$<CONFIG:Release>:QT_NO_WARNING_OUTPUT>

		# Build type
		$<$<CONFIG:Release>:RELEASE>
		$<$<NOT:$<CONFIG:Release>>:DEBUG>

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

		# To avoid including too many things from Windows headers
		$<$<PLATFORM_ID:Windows>:VC_EXTRALEAN>
		$<$<PLATFORM_ID:Windows>:WIN32_LEAN_AND_MEAN>
		$<$<PLATFORM_ID:Windows>:NOMINMAX>
)

#
# Compile options
#
target_compile_options (MediaViewer
	PRIVATE
		# Warning levels
		$<$<CXX_COMPILER_ID:MSVC>:/W4 $<$<BOOL:${WARNINGS_AS_ERRORS}>:/WX>>
		$<$<CXX_COMPILER_ID:Clang>:-Wall $<$<BOOL:${WARNINGS_AS_ERRORS}>:-Werror>>
		$<$<CXX_COMPILER_ID:GNU>:-Wall $<$<BOOL:${WARNINGS_AS_ERRORS}>:-Werror>>
)

#
# Install mediaviewer
#
install_qt_target (MediaViewer "${CMAKE_CURRENT_SOURCE_DIR}/Sources"
	RUNTIME DESTINATION .
	LIBRARY DESTINATION .
	ARCHIVE DESTINATION .
)
