--
-- tests/base/test_genie_command.lua
-- Test the initialization of the _GENIE_COMMAND global.
-- Copyright (c) 2012 Jason Perkins and the Premake project
--

	T.genie_command = { }
	local suite = T.genie_command


	function suite.valueIsSet()
		local filename = iif(os.is("windows"), "genie.exe", "genie")
		test.isequal(path.getabsolute("../bin/debug/" .. filename), _GENIE_COMMAND)
	end
