
--
-- Load the Qt addon
--
require( "qt" )
local qt = premake.extensions.qt

--
-- Load user config
--
dofile( "config.lua" )

--
-- Load createinstall action
--
dofile( "install.lua" )

--
-- If no action, return
--
if _ACTION == nil then
	return
end


--
-- Our solution
--
solution "MediaViewer"

	-- platforms and configurations
	configurations { "Debug", "Release", "Retail" }
	platforms { "x32", "x64" }

	-- location of the projet files
	location ( "Projects/" .. _ACTION )

	--
	-- Project
	--
	project "MediaViewer"

		-- project type
		kind "WindowedApp"
		language "C++"

		-- output folders
		objdir ( "Output/obj/%{prj.name}/%{cfg.buildcfg}/%{cfg.platform}" )
		targetdir ( "Output/bin/%{cfg.buildcfg}/%{cfg.platform}" )

		-- files of the project
		files {
			"Sources/**",
			"Resources/**"
		}
		vpaths {
			["*"] = { "Sources" },
			["Generated/*"] = { "Output/obj/MediaViewer" },
		}
		includedirs { "Sources" }

		-- precompiled headers
		pchsource "Sources/MediaViewerPCH.cpp"
		pchheader "MediaViewerPCH.h"

		-- copy the import qml file to the output directory
		filter "files:**/imports.qml"
			buildmessage "Deploying %{file.name}"
			buildcommands { "copy \"%{file.relpath:gsub('/', '\\')}\" \"%{cfg.buildtarget.directory:gsub('/', '\\')}\\%{file.name}\"" }
			buildoutputs { "%{cfg.buildtarget.directory}/%{file.name}" }

		-- copy the qmldir file to the target dir
		filter "files:**/qmldir"
			buildmessage "Deploying %{file.name}"
			buildcommands { "copy \"%{file.relpath:gsub('/', '\\')}\" \"%{cfg.buildtarget.directory:gsub('/', '\\')}\\%{file.name}\"" }
			buildoutputs { "%{cfg.buildtarget.directory}/%{file.name}" }

		-- enable Qt
		filter {}
		qt.enable()
		qtmodules { "core", "qml", "gui", "quick", "widgets", "multimedia" }

		-- Qt addon configuration
		filter {}					qtprefix "Qt5"
		filter ( "Debug")			qtsuffix "d"
		filter ( "platforms:x32" )	qtpath ( QT_PATH.x32 )
		filter ( "platforms:x64" )	qtpath ( QT_PATH.x64 )

		-- debugging
		filter ( "platforms:x32" )	debugenvs { "PATH=" .. QT_PATH.x32:gsub('/', '\\') .. "\\bin;%PATH%;" }
		filter ( "platforms:x64" )	debugenvs { "PATH=" .. QT_PATH.x64:gsub('/', '\\') .. "\\bin;%PATH%;" }
		filter { }					debugdir "Sources/QML"
		-- filter { }					debugenvs { "QML_IMPORT_TRACE=1" }

		-- configure options for all configurations
		filter { }

			warnings "Extra"
			flags { "MultiProcessorCompile" }

		-- debug configuration
		filter "configurations:Debug"

			defines { "DEBUG", "_DEBUG", "QT_QML_DEBUG" }
			optimize "Off"
			symbols "On"

		-- release configurations
		filter "configurations:not Debug"

			defines { "NDEBUG", "QT_NO_DEBUG" }
			optimize "On"

		-- release configuration
		filter "configurations:Release"

			defines { "RELEASE", "QT_QML_DEBUG" }
			symbols "On"

		-- retail configuration
		filter "configurations:Retail"

			defines { "RETAIL" }
			symbols "Off"

		-- windows, disable deprecated warnings
		filter "action:vs*"

			defines {
				"_CRT_SECURE_NO_WARNINGS",
				"_SCL_SECURE_NO_WARNINGS"
			}

		-- reset configuration
		filter {}
