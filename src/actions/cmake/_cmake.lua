--
-- _cmake.lua
-- Define the CMake action(s).
-- Copyright (c) 2015 Miodrag Milanovic
--

genie.cmake = { }

--
-- Register the "cmake" action
--

newaction {
	trigger         = "cmake",
	shortname       = "CMake",
	description     = "Generate CMake project files",
	valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Bundle" },
	valid_languages = { "C", "C++" },
	valid_tools     = {
		cc   = { "gcc" },
	},
	onsolution = function(sln)
		genie.generate(sln, "CMakeLists.txt", genie.cmake.workspace)
	end,
	onproject = function(prj)
		genie.generate(prj, "%%/CMakeLists.txt", genie.cmake.project)
	end,
	oncleansolution = function(sln)
		genie.clean.file(sln, "CMakeLists.txt")
	end,
	oncleanproject = function(prj)
		genie.clean.file(prj, "%%/CMakeLists.txt")
	end
}
