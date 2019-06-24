--
-- ow.lua
-- Provides Open Watcom-specific configuration strings.
-- Copyright (c) 2008 Jason Perkins and the Premake project
--

	genie.ow = { }
	genie.ow.namestyle = "windows"


--
-- Set default tools
--

	genie.ow.cc     = "WCL386"
	genie.ow.cxx    = "WCL386"
	genie.ow.ar     = "ar"


--
-- Translation of GENie flags into OpenWatcom flags
--

	local cflags =
	{
		PedanticWarnings = "-wx",
		ExtraWarnings    = "-wx",
		FatalWarning     = "-we",
		FloatFast        = "-omn",
		FloatStrict      = "-op",
		Optimize         = "-ox",
		OptimizeSize     = "-os",
		OptimizeSpeed    = "-ot",
		Symbols          = "-d2",
	}

	local cxxflags =
	{
		NoExceptions   = "-xd",
		NoRTTI         = "-xr",
	}



--
-- No specific platform support yet
--

	genie.ow.platforms =
	{
		Native = {
			flags = ""
		},
	}



--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function genie.ow.getcppflags(cfg)
		return {}
	end

	function genie.ow.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		if (cfg.flags.Symbols) then
			table.insert(result, "-hw")   -- Watcom debug format for Watcom debugger
		end
		return result
	end

	function genie.ow.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end



--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function genie.ow.getldflags(cfg)
		local result = { }

		if (cfg.flags.Symbols) then
			table.insert(result, "op symf")
		end

		return result
	end


--
-- Returns a list of project-relative paths to external library files.
-- This function should examine the linker flags and return any that seem to be
-- a real path to a library file (e.g. "path/to/a/library.a", but not "GL").
-- Useful for adding to targets to trigger a relink when an external static
-- library gets updated.
-- Not currently supported on this toolchain.
--
	function genie.ow.getlibfiles(cfg)
		local result = {}
		return result
	end

--
-- Returns a list of linker flags for library search directories and
-- library names.
--

	function genie.ow.getlinkflags(cfg)
		local result = { }
		return result
	end



--
-- Decorate defines for the command line.
--

	function genie.ow.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end



--
-- Decorate include file search paths for the command line.
--

	function genie.ow.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, '-I "' .. dir .. '"')
		end
		return result
	end

