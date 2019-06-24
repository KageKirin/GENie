--
-- tests/actions/make/test_makesettings.lua
-- Tests makesettings lists in generated makefiles.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--
	
	T.make_settings = { }
	local suite = T.make_settings
	local make = genie.make
	
	local sln, prj, cfg
	
	function suite.setup()
		_ACTION = "gmake"

		sln = solution("MySolution")
		configurations { "Debug", "Release" }		
		makesettings { "SOLUTION_LEVEL_SETTINGS" }
		
		project("MyProject")
		makesettings { "PROJECT_LEVEL_SETTINGS" }
		
		configuration { "Debug" }
		makesettings { "DEBUG_LEVEL_SETTINGS" }
		
		configuration { "Release" }
		makesettings { "RELEASE_LEVEL_SETTINGS" }
		
		genie.bake.buildconfigs()
		prj = genie.solution.getproject(sln, 1)
		cfg = genie.getconfig(prj, "Debug")
	end


	function suite.writesProjectSettings()
		make.settings(prj, genie.gcc)
		test.capture [[
SOLUTION_LEVEL_SETTINGS
PROJECT_LEVEL_SETTINGS

  		]]
	end

	function suite.writesConfigSettings()
		make.settings(cfg, genie.gcc)
		test.capture [[
DEBUG_LEVEL_SETTINGS

 		]]
	end

