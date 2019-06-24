--
-- vs2010.lua
-- Baseline support for Visual Studio 2010.
-- Copyright (c) 2013 Jason Perkins and the Premake project
--

	local vc2010 = genie.vstudio.vc2010
	local vstudio = genie.vstudio

---
-- Register a command-line action for Visual Studio 2010.
---

	newaction
	{
		trigger         = "vs2010",
		shortname       = "Visual Studio 2010",
		description     = "Generate Microsoft Visual Studio 2010 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Bundle" },

		valid_languages = { "C", "C++", "C#"},

		valid_tools     = {
			cc     = { "msc"   },
			dotnet = { "msnet" },
		},

		onsolution = function(sln)
			genie.generate(sln, "%%.sln", vstudio.sln2005.generate)
		end,

		onproject = function(prj)
			if genie.isdotnetproject(prj) then
				genie.generate(prj, "%%.csproj", vstudio.cs2005.generate)
				genie.generate(prj, "%%.csproj.user", vstudio.cs2005.generate_user)
			else
			genie.generate(prj, "%%.vcxproj", genie.vs2010_vcxproj)
			genie.generate(prj, "%%.vcxproj.user", genie.vs2010_vcxproj_user)
			genie.generate(prj, "%%.vcxproj.filters", vstudio.vc2010.generate_filters)
			end
		end,

		oncleansolution = genie.vstudio.cleansolution,
		oncleanproject  = genie.vstudio.cleanproject,
		oncleantarget   = genie.vstudio.cleantarget,

		vstudio = {
			productVersion  = "8.0.30703",
			solutionVersion = "11",
			targetFramework = "4.0",
			toolsVersion    = "4.0",
			supports64bitEditContinue = false,
			intDirAbsolute  = false,
		}
	}
