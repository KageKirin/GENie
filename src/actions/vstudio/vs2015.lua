--
-- vs2015.lua
-- Baseline support for Visual Studio 2015.
--

	genie.vstudio.vc2015 = {}
	local vc2015 = genie.vstudio.vc2015
	local vstudio = genie.vstudio


---
-- Register a command-line action for Visual Studio 2015.
---

	newaction
	{
		trigger         = "vs2015",
		shortname       = "Visual Studio 2015",
		description     = "Generate Microsoft Visual Studio 2015 project files",
		os              = "windows",

		valid_kinds     = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Bundle" },

		valid_languages = { "C", "C++", "C#" },

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
				genie.vstudio.needAppxManifest = false
				genie.generate(prj, "%%.vcxproj", genie.vs2010_vcxproj)
				genie.generate(prj, "%%.vcxproj.user", genie.vs2010_vcxproj_user)
				genie.generate(prj, "%%.vcxproj.filters", vstudio.vc2010.generate_filters)

				if genie.vstudio.needAppxManifest then
					genie.generate(prj, "%%/Package.appxmanifest", genie.vs2010_appxmanifest)
				end
			end
		end,


		oncleansolution = genie.vstudio.cleansolution,
		oncleanproject  = genie.vstudio.cleanproject,
		oncleantarget   = genie.vstudio.cleantarget,

		vstudio = {
			solutionVersion = "12",
			targetFramework = "4.5",
			toolsVersion    = "14.0",
			windowsTargetPlatformVersion = "8.1",
			supports64bitEditContinue    = true,
			intDirAbsolute  = false,
		}
	}
