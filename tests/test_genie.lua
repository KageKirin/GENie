--
-- tests/test_genie.lua
-- Automated test suite for the GENie support functions.
-- Copyright (c) 2008-2009 Jason Perkins and the Premake project
--


	T.genie = { }


--
-- genie.checktools() tests
--

	function T.genie.checktools_SetsDefaultTools()
		_ACTION = "gmake"
		genie.checktools()
		test.isequal("gcc", _OPTIONS.cc)
		test.isequal("mono", _OPTIONS.dotnet)
	end
	
	
	function T.genie.checktools_Fails_OnToolMismatch()
		_ACTION = "gmake"
		_OPTIONS["cc"] = "xyz"
		ok, err = genie.checktools()
		test.isfalse( ok )
		test.isequal("the GNU Make action does not support /cc=xyz (yet)", err)
	end



--
-- generate() tests
--

	function T.genie.generate_OpensCorrectFile()
		prj = { name = "MyProject", location = "MyLocation" }
		genie.generate(prj, "%%.prj", function () end)
		test.openedfile("MyLocation/MyProject.prj")
	end

	function T.genie.generate_ClosesFile()
		prj = { name = "MyProject", location = "MyLocation" }
		genie.generate(prj, "%%.prj", function () end)
		test.closedfile(true)
	end
