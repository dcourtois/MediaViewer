#
# This contains all boring setup stuff needed by the main CMake file.
#

#
# Configure Qt.
#
# This is configured for my various computers installation so that I don't have to bother, but you can
# customize that to your needs during configure:
#
# -DQT_ROOT=<path> : make this point to the lib/cmake folder of your Qt installation.
#
set (QT_VERSIONS ${QT_VERSIONS} "install" "official/5.15.2" "official/5.15.1")
set (QT_ROOT ${QT_ROOT} "C:/Development/Libs/Qt" "D:/Development/Libs/Qt" "~/Development/Libs/Qt" )
set (QT_SUFFIX ${QT_SUFFIX} "lib/cmake" "msvc2019_64/lib/cmake")
set (QT_COMPONENTS Multimedia Network Qml Quick QuickControls2 Svg Xml)
set (QT_VERSION 5)

#
# automatically handle moc and rcc
#
set (CMAKE_AUTOMOC ON)
set (CMAKE_AUTORCC ON)

# windows specific configurations
if (WIN32)

	foreach (CONF IN ITEMS "" "_RELEASE" "_DEBUG" "_RELWITHDEBINFO" "_MINSIZEREL")
		# warnings are set per targets
		string (REGEX REPLACE "[/\\-]W[1-4]" "" CMAKE_CXX_FLAGS${CONF} "${CMAKE_CXX_FLAGS${CONF}}")
		# force release runtime on all targets
		string (REGEX REPLACE "[/\\-]M[TD]d?" "/MD" CMAKE_CXX_FLAGS${CONF} "${CMAKE_CXX_FLAGS${CONF}}")
	endforeach ()

endif ()
