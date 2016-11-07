
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
-- This function contains common configuration for the projects
--
function configure()

	-- Qt addon configuration
	filter {}					qtprefix "Qt5"
	filter ( "Debug")			qtsuffix "d"
	filter ( "platforms:x32" )	qtpath ( QT_PATH.x32 )
	filter ( "platforms:x64" )	qtpath ( QT_PATH.x64 )

	-- debugging
	filter ( "platforms:x32" )	debugenvs { "PATH=" .. QT_PATH.x32:gsub('/', '\\') .. "\\bin;%PATH%;" }
	filter ( "platforms:x64" )	debugenvs { "PATH=" .. QT_PATH.x64:gsub('/', '\\') .. "\\bin;%PATH%;" }
	filter { }					debugdir "MediaViewer/Sources/QML"
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

end


--
-- Our solution
--
solution "MediaViewer"

	configurations { "Debug", "Release", "Retail" }
	platforms { "x32", "x64" }

	location ( "Projects/" .. _ACTION )

	startproject "MediaViewer"

	dofile ( "MediaViewer/MediaViewer.lua" )
	configure()
	dependson "MediaViewerLib"

	dofile ( "MediaViewerLib/MediaViewerLib.lua" )
	configure()
