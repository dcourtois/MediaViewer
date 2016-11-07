local qt = premake.extensions.qt

project "MediaViewerLib"

	-- project type
	kind "SharedLib"
	language "C++"

	-- output folders
	objdir ( "../Output/obj/%{prj.name}/%{cfg.buildcfg}/%{cfg.platform}" )
	targetdir ( "../Output/bin/%{cfg.buildcfg}/%{cfg.platform}/%{prj.name}" )

	-- enable Qt for this project
	qt.enable()
	qtmodules { "core", "qml", "quick", "gui", "svg", "widgets", "network" }

	-- files of the project
	files {
		"Sources/**"
	}
	vpaths {
		["*"] = { "Sources" },
		["Generated/*"] = { "../Output/obj/" },
	}

	-- includes
	includedirs { "Sources" }

	-- pch
	pchsource "Sources/MediaViewerLibPCH.cpp"
	pchheader "MediaViewerLibPCH.h"

	-- export dll
	defines { "EXPORT_DLL" }

	-- copy the qmldir file to the target dir
	filter "files:**/qmldir"
		buildmessage "Deploying %{file.name}"
		buildcommands { "copy \"%{file.relpath:gsub('/', '\\')}\" \"%{cfg.buildtarget.directory:gsub('/', '\\')}\\%{file.name}\"" }
		buildoutputs { "%{cfg.buildtarget.directory}/%{file.name}" }
