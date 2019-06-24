--
-- _xcode.lua
-- Define the Apple XCode action and support functions.
-- Copyright (c) 2009 Jason Perkins and the Premake project
--

	genie.xcode = { }

--
-- Verify only single target kind for Xcode project
--
-- @param prj
--    Project to be analyzed
--

	function genie.xcode.checkproject(prj)
		-- Xcode can't mix target kinds within a project
		local last
		for cfg in genie.eachconfig(prj) do
			if last and last ~= cfg.kind then
				error("Project '" .. prj.name .. "' uses more than one target kind; not supported by Xcode", 0)
			end
			last = cfg.kind
		end
	end

--
-- Set default toolset
--

	genie.xcode.toolset = "macosx"
