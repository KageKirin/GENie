	genie.fastbuild = { }
	local fastbuild = genie.fastbuild

	newaction
	{
		trigger = "vs2015-fastbuild",
		shortname = "FASTBuild VS2015",
		description = "Generate FASTBuild configuration files for Visual Studio 2015.",

		valid_kinds = {
			"ConsoleApp",
			"WindowedApp",
			"StaticLib",
			"SharedLib",
			"Bundle",
		},

		valid_languages = {
			"C",
			"C++"
		},

		valid_tools = {
			cc = {
				"msc"
			},
		},

		onsolution = function(sln)
			genie.generate(sln, "fbuild.bff", genie.fastbuild.solution)
		end,

		onproject = function(prj)
			genie.generate(prj, "%%.bff", genie.fastbuild.project)
		end,

		oncleansolution = function(sln)
			genie.clean.file(sln, "fbuild.bff")
		end,

		oncleanproject  = function(prj)
			genie.clean.file(prj, "%%.bff")
		end,
	}
