QT += \
    qml \
    gui \
    quick \
	quickcontrols2 \
    widgets \
    multimedia

CONFIG += \
    c++11 \
    precompile_header

SOURCES += \
    Sources/Main.cpp \
    Sources/MediaViewerPCH.cpp \
    Sources/RegisterQMLTypes.cpp \
    Sources/ImageProviders/FolderIconProvider.cpp \
    Sources/Models/Folder.cpp \
    Sources/Models/FolderModel.cpp \
    Sources/Models/Media.cpp \
    Sources/Models/MediaModel.cpp \
    Sources/Utils/Cursor.cpp \
    Sources/Utils/FileSystem.cpp \
    Sources/Utils/Job.cpp \
    Sources/Utils/Memory.cpp \
    Sources/Utils/Misc.cpp

RESOURCES += \
    Sources/QML/QML.qrc \
    Resources/Resources.qrc

HEADERS += \
    Sources/MediaViewerPCH.h \
    Sources/RegisterQMLTypes.h \
    Sources/ImageProviders/FolderIconProvider.h \
    Sources/Models/Folder.h \
    Sources/Models/Folder.inl \
    Sources/Models/FolderModel.h \
    Sources/Models/FolderModel.inl \
    Sources/Models/Media.h \
    Sources/Models/Media.inl \
    Sources/Models/MediaModel.h \
    Sources/Models/MediaModel.inl \
    Sources/Utils/Cursor.h \
    Sources/Utils/FileSystem.h \
    Sources/Utils/Job.h \
    Sources/Utils/Memory.h \
    Sources/Utils/Misc.h \
    Sources/Utils/Misc.inl

#
# Global config
#
INCLUDEPATH += Sources
PRECOMPILED_HEADER = Sources/MediaViewerPCH.h

#
# Platform specifics
#
linux {
    DEFINES += LINUX
}
win32 {
    DEFINES += WINDOWS
}
mac {
    DEFINES += MACOS
}
