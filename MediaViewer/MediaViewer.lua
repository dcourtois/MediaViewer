local qt = premake.extensions.qt

project "MediaViewer"

	-- project type
	kind "WindowedApp"
	language "C++"

	-- output folders
	objdir ( "../Output/obj/%{prj.name}/%{cfg.buildcfg}/%{cfg.platform}" )
	targetdir ( "../Output/bin/%{cfg.buildcfg}/%{cfg.platform}" )

	-- enable Qt for this project
	qt.enable()
	qtmodules { "core", "qml", "gui", "quick", "widgets", "multimedia" }

	-- files of the project
	files {
		"Sources/**",
		"Resources/**"
	}
	vpaths {
		["*"] = { "Sources" },
		["Generated/*"] = { "../Output/obj/MediaViewer" },
	}

	-- use media viewer lib
	includedirs { "../MediaViewerLib/Sources" }
	links { "MediaViewerLib" }

	-- precompiled headers
	pchsource "Sources/MediaViewerPCH.cpp"
	pchheader "MediaViewerPCH.h"

	-- copy the import qml file to the output directory
	filter "files:**/imports.qml"
		buildmessage "Deploying %{file.name}"
		buildcommands { "copy \"%{file.relpath:gsub('/', '\\')}\" \"%{cfg.buildtarget.directory:gsub('/', '\\')}\\%{file.name}\"" }
		buildoutputs { "%{cfg.buildtarget.directory}/%{file.name}" }

	--
	-- uncomment to enable verbose QML import logs
	--
	-- filter ( "Debug" )			debugenvs { "QML_IMPORT_TRACE=1"}
