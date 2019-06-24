--
-- tests/base/test_api.lua
-- Automated test suite for the project API support functions.
-- Copyright (c) 2008-2011 Jason Perkins and the Premake project
--

	T.api = { }
	local suite = T.api

	local sln
	function suite.setup()
		sln = solution "MySolution"
	end


--
-- genie.getobject() tests
--

	function suite.getobject_RaisesError_OnNoContainer()
		genie.CurrentContainer = nil
		c, err = genie.getobject("container")
		test.istrue(c == nil)
		test.isequal("no active solution or project", err)
	end
	
	function suite.getobject_RaisesError_OnNoActiveSolution()
		genie.CurrentContainer = { }
		c, err = genie.getobject("solution")
		test.istrue(c == nil)
		test.isequal("no active solution", err)
	end
	
	function suite.getobject_RaisesError_OnNoActiveConfig()
		genie.CurrentConfiguration = nil
		c, err = genie.getobject("config")
		test.istrue(c == nil)
		test.isequal("no active solution, project, or configuration", err)
	end
		
	
--
-- genie.setarray() tests
--

	function suite.setarray_Inserts_OnStringValue()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { }
		genie.setarray("config", "myfield", "hello")
		test.isequal("hello", genie.CurrentConfiguration.myfield[1])
	end

	function suite.setarray_Inserts_OnTableValue()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { }
		genie.setarray("config", "myfield", { "hello", "goodbye" })
		test.isequal("hello", genie.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", genie.CurrentConfiguration.myfield[2])
	end

	function suite.setarray_Appends_OnNewValues()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { "hello" }
		genie.setarray("config", "myfield", "goodbye")
		test.isequal("hello", genie.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", genie.CurrentConfiguration.myfield[2])
	end

	function suite.setarray_FlattensTables()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { }
		genie.setarray("config", "myfield", { {"hello"}, {"goodbye"} })
		test.isequal("hello", genie.CurrentConfiguration.myfield[1])
		test.isequal("goodbye", genie.CurrentConfiguration.myfield[2])
	end
	
	function suite.setarray_RaisesError_OnInvalidValue()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { }
		ok, err = pcall(function () genie.setarray("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function suite.setarray_CorrectsCase_OnConstrainedValue()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = { }
		genie.setarray("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", genie.CurrentConfiguration.myfield[1])
	end
	
	

--
-- genie.setstring() tests
--

	function suite.setstring_Sets_OnNewProperty()
		genie.CurrentConfiguration = { }
		genie.setstring("config", "myfield", "hello")
		test.isequal("hello", genie.CurrentConfiguration.myfield)
	end

	function suite.setstring_Overwrites_OnExistingProperty()
		genie.CurrentConfiguration = { }
		genie.CurrentConfiguration.myfield = "hello"
		genie.setstring("config", "myfield", "goodbye")
		test.isequal("goodbye", genie.CurrentConfiguration.myfield)
	end
	
	function suite.setstring_RaisesError_OnInvalidValue()
		genie.CurrentConfiguration = { }
		ok, err = pcall(function () genie.setstring("config", "myfield", "bad", { "Good", "Better", "Best" }) end)
		test.isfalse(ok)
	end
		
	function suite.setstring_CorrectsCase_OnConstrainedValue()
		genie.CurrentConfiguration = { }
		genie.setstring("config", "myfield", "better", { "Good", "Better", "Best" })
		test.isequal("Better", genie.CurrentConfiguration.myfield)
	end


--
-- genie.setkeyvalue() tests
--

	function suite.setkeyvalue_Inserts_OnStringValue()
		genie.CurrentConfiguration = { }
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = "*.h" })
		test.isequal({"*.h"}, genie.CurrentConfiguration.vpaths["Headers"])
	end
	
	function suite.setkeyvalue_Inserts_OnTableValue()
		genie.CurrentConfiguration = { }
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = {"*.h","*.hpp"} })
		test.isequal({"*.h","*.hpp"}, genie.CurrentConfiguration.vpaths["Headers"])
	end
	
	function suite.setkeyvalue_Inserts_OnEmptyStringKey()
		genie.CurrentConfiguration = { }
		genie.setkeyvalue("config", "vpaths", { [""] = "src" })
		test.isequal({"src"}, genie.CurrentConfiguration.vpaths[""])
	end
	
	function suite.setkeyvalue_RaisesError_OnString()
		genie.CurrentConfiguration = { }
		ok, err = pcall(function () genie.setkeyvalue("config", "vpaths", "Headers") end)
		test.isfalse(ok)
	end
	
	function suite.setkeyvalue_InsertsString_IntoExistingKey()
		genie.CurrentConfiguration = { }
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = "*.h" })
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = "*.hpp" })
		test.isequal({"*.h","*.hpp"}, genie.CurrentConfiguration.vpaths["Headers"])
	end
	
	function suite.setkeyvalue_InsertsTable_IntoExistingKey()
		genie.CurrentConfiguration = { }
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = {"*.h"} })
		genie.setkeyvalue("config", "vpaths", { ["Headers"] = {"*.hpp"} })
		test.isequal({"*.h","*.hpp"}, genie.CurrentConfiguration.vpaths["Headers"])
	end


--
-- accessor tests
--

	function suite.accessor_CanRetrieveString()
		sln.blocks[1].kind = "ConsoleApp"
		test.isequal("ConsoleApp", kind())
	end


--
-- solution() tests
--

	function suite.solution_SetsCurrentContainer_OnName()
		test.istrue(sln == genie.CurrentContainer)
	end

	function suite.solution_CreatesNewObject_OnNewName()
		solution "MySolution2"
		test.isfalse(sln == genie.CurrentContainer)
	end

	function suite.solution_ReturnsPrevious_OnExistingName()
		solution "MySolution2"
		local sln2 = solution "MySolution"
		test.istrue(sln == sln2)
	end

	function suite.solution_SetsCurrentContainer_OnExistingName()
		solution "MySolution2"
		solution "MySolution"
		test.istrue(sln == genie.CurrentContainer)
	end

	function suite.solution_ReturnsNil_OnNoActiveSolutionAndNoName()
		genie.CurrentContainer = nil
		test.isnil(solution())
	end
	
	function suite.solution_ReturnsCurrentSolution_OnActiveSolutionAndNoName()
		test.istrue(sln == solution())
	end
	
	function suite.solution_ReturnsCurrentSolution_OnActiveProjectAndNoName()
		project "MyProject"
		test.istrue(sln == solution())
	end

	function suite.solution_LeavesProjectActive_OnActiveProjectAndNoName()
		local prj = project "MyProject"
		solution()
		test.istrue(prj == genie.CurrentContainer)
	end

	function suite.solution_LeavesConfigActive_OnActiveSolutionAndNoName()
		local cfg = configuration "windows"
		solution()
		test.istrue(cfg == genie.CurrentConfiguration)
	end	

	function suite.solution_LeavesConfigActive_OnActiveProjectAndNoName()
		project "MyProject"
		local cfg = configuration "windows"
		solution()
		test.istrue(cfg == genie.CurrentConfiguration)
	end	
	
	function suite.solution_SetsName_OnNewName()
		test.isequal("MySolution", sln.name)
	end
	
	function suite.solution_AddsNewConfig_OnNewName()
		test.istrue(#sln.blocks == 1)
	end

	function suite.solution_AddsNewConfig_OnName()
		local num = #sln.blocks
		solution "MySolution"
		test.istrue(#sln.blocks == num + 1)
	end
	


--
-- configuration() tests
--
		
	function suite.configuration_RaisesError_OnNoContainer()
		genie.CurrentContainer = nil
		local fn = function() configuration{"Debug"} end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function suite.configuration_SetsCurrentConfiguration_OnKeywords()
		local cfg = configuration {"Debug"}
		test.istrue(genie.CurrentConfiguration == cfg)
	end

	function suite.configuration_AddsToContainer_OnKeywords()
		local cfg = configuration {"Debug"}
		test.istrue(cfg == sln.blocks[#sln.blocks])
	end
	
	function suite.configuration_ReturnsCurrent_OnNoKeywords()
		local cfg = configuration()
		test.istrue(cfg == sln.blocks[1])
	end

	function suite.configuration_SetsTerms()
		local cfg = configuration {"aa", "bb"}
		test.isequal({"aa", "bb"},  cfg.terms)
	end

	function suite.configuration_SetsTermsWithNestedTables()
		local cfg = configuration { {"aa", "bb"}, "cc" }
		test.isequal({"aa", "bb", "cc"},  cfg.terms)
	end

	function suite.configuration_CanReuseTerms()
		local cfg = configuration { "aa", "bb" }
		local cfg2 = configuration { cfg.terms, "cc" }
		test.isequal({"aa", "bb", "cc"},  cfg2.terms)
	end


--
-- project() tests
--
		
	function suite.project_RaisesError_OnNoSolution()
		genie.CurrentContainer = nil
		local fn = function() project("MyProject") end
		ok, err = pcall(fn)
		test.isfalse(ok)
	end

	function suite.project_SetsCurrentContainer_OnName()
		local prj = project "MyProject"
		test.istrue(prj == genie.CurrentContainer)
	end
	
	function suite.project_CreatesNewObject_OnNewName()
		local prj = project "MyProject"
		local pr2 = project "MyProject2"
		test.isfalse(prj == genie.CurrentContainer)
	end

	function suite.project_AddsToSolution_OnNewName()
		local prj = project "MyProject"
		test.istrue(prj == sln.projects[1])
	end
	
	function suite.project_ReturnsPrevious_OnExistingName()
		local prj = project "MyProject"
		local pr2 = project "MyProject2"
		local pr3 = project "MyProject"
		test.istrue(prj == pr3)
	end
	
	function suite.project_SetsCurrentContainer_OnExistingName()
		local prj = project "MyProject"
		local pr2 = project "MyProject2"
		local pr3 = project "MyProject"
		test.istrue(prj == genie.CurrentContainer)
	end
		
	function suite.project_ReturnsNil_OnNoActiveProjectAndNoName()
		test.isnil(project())
	end
	
	function suite.project_ReturnsCurrentProject_OnActiveProjectAndNoName()
		local prj = project "MyProject"
		test.istrue(prj == project())
	end
	
	function suite.project_LeavesProjectActive_OnActiveProjectAndNoName()
		local prj = project "MyProject"
		project()
		test.istrue(prj == genie.CurrentContainer)
	end
	
	function suite.project_LeavesConfigActive_OnActiveProjectAndNoName()
		local prj = project "MyProject"
		local cfg = configuration "Windows"
		project()
		test.istrue(cfg == genie.CurrentConfiguration)
	end
		
	function suite.project_SetsName_OnNewName()
		prj = project("MyProject")
		test.isequal("MyProject", prj.name)
	end
	
	function suite.project_SetsSolution_OnNewName()
		prj = project("MyProject")
		test.istrue(sln == prj.solution)
	end

	function suite.project_SetsConfiguration()
		prj = project("MyProject")
		test.istrue(genie.CurrentConfiguration == prj.blocks[1])
	end

	function suite.project_SetsUUID()
		local prj = project "MyProject"
		test.istrue(prj.uuid)
	end
			


--
-- uuid() tests
--

	function suite.uuid_makes_uppercase()
		genie.CurrentContainer = {}
		uuid "7CBB5FC2-7449-497f-947F-129C5129B1FB"
		test.isequal(genie.CurrentContainer.uuid, "7CBB5FC2-7449-497F-947F-129C5129B1FB")
	end


--
-- Fields with allowed value lists should be case-insensitive.
--

	function suite.flags_onCaseMismatch()
		genie.CurrentConfiguration = {}
		flags "symbols"
		test.isequal(genie.CurrentConfiguration.flags[1], "Symbols")
	end

	function suite.flags_onCaseMismatchAndAlias()
		genie.CurrentConfiguration = {}
		flags "optimisespeed"
		test.isequal(genie.CurrentConfiguration.flags[1], "OptimizeSpeed")
	end
		
