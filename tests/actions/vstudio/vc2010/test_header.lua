--
-- tests/actions/vstudio/vc2010/test_header.lua
-- Validate generation of the project file header block.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.vstudio_vs2010_header = { }
	local suite = T.vstudio_vs2010_header
	local vc2010 = genie.vstudio.vc2010


--
-- Setup 
--

	local sln, prj
	
	function suite.setup()
		_ACTION = 'vs2010'
		sln = test.createsolution()
		genie.bake.buildconfigs()
		prj = genie.solution.getproject(sln, 1)
		sln.vstudio_configs = genie.vstudio.buildconfigs(sln)
	end


--
-- Tests
--

	function suite.On2010_WithNoTarget()
		vc2010.header()
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end

	function suite.On2010_WithTarget()
		vc2010.header("Build")
		test.capture [[
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
		]]
	end
