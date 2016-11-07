
--
-- This action is used to create an installable folder with the release application
--
newaction {
	trigger = "createinstall",
	description = "Create a clean installation folder containing the application and its dependencies",
	execute = function ()
		-- get the options
		local _configuration	= _OPTIONS["configuration"] or "Retail"
		local _platform			= _OPTIONS["platform"] or "x64"

		-- create the command, and normalize path for windows
		local command = QT_PATH[_platform] .. "/bin/windeployqt.exe"
		command = command .. " --verbose 3"
		command = command .. " --no-translations"
		command = command .. " --no-opengl-sw"
		command = command .. (_configuration == "Debug" and " --debug" or " --release")
		command = command .. " --qmldir \"Output/bin/" .. _configuration .. "/" .. _platform .. "/\""
		command = command .. " \"Output/bin/" .. _configuration .. "/" .. _platform .. "/" .. PROJECT_NAME .. ".exe\""

		-- note : a bit messy, --dir doesn't seem to work, so we need to set the Qt bin folder in the PATH env var
		--        in the same call to os.execute as the one containing windeployqt ...
		os.execute("set PATH=%PATH%;" .. QT_PATH[_platform]:gsub("/", "\\") .. "\\bin && " .. command)

		-- cleanup some unused stuff
		os.remove("Output/bin/" .. _configuration .. "/" .. _platform .. "/*.pdb")
		os.remove("Output/bin/" .. _configuration .. "/" .. _platform .. "/*.qm")
		os.remove("Output/bin/" .. _configuration .. "/" .. _platform .. "/qmltooling/*")
		os.execute("rmdir /Q \"Output\\bin\\" .. _configuration .. "\\" .. _platform .. "\\qmltooling\"")
	end
}

--
-- Set the configuration to package
--
newoption {
	trigger = "configuration",
	value = "CONFIG_NAME",
	description = "When createinstall action is used, set the configuration to package.",
	allowed = {
		{ "Debug",		"Debug" },
		{ "Release",	"Release" },
		{ "Retail",		"Retail (default)" }
	}
}

--
-- Set the platform to package
--
newoption {
	trigger = "platform",
	value = "PLATFORM_NAME",
	description = "When createinstall action is used, set the platform to package.",
	allowed = {
		{ "x32",	"x32" },
		{ "x64",	"x64 (default)" }
	}
}
