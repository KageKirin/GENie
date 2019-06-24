--
-- snc.lua
-- Provides Sony SNC-specific configuration strings.
-- Copyright (c) 2010 Jason Perkins and the Premake project
--


	genie.snc = { }


-- TODO: Will cfg.system == "windows" ever be true for SNC? If
-- not, remove the conditional blocks that use this test.

--
-- Set default tools
--

	genie.snc.cc     = "snc"
	genie.snc.cxx    = "g++"
	genie.snc.ar     = "ar"


--
-- Translation of GENie flags into SNC flags
--

	local cflags =
	{
		PedanticWarnings = "-Xdiag=2",
		ExtraWarnings    = "-Xdiag=2",
		FatalWarnings    = "-Xquit=2",
	}

	local cxxflags =
	{
		NoExceptions   = "", -- No exceptions is the default in the SNC compiler.
		NoRTTI         = "-Xc-=rtti",
	}


--
-- Map platforms to flags
--

	genie.snc.platforms =
	{
		PS3 = {
			cc         = "ppu-lv2-g++",
			cxx        = "ppu-lv2-g++",
			ar         = "ppu-lv2-ar",
			cppflags   = "-MMD -MP",
		}
	}

	local platforms = genie.snc.platforms


--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function genie.snc.getcppflags(cfg)
		local result = { }
		table.insert(result, platforms[cfg.platform].cppflags)
		return result
	end

	function genie.snc.getcflags(cfg)
		local result = table.translate(cfg.flags, cflags)
		table.insert(result, platforms[cfg.platform].flags)
		if cfg.kind == "SharedLib" then
			table.insert(result, "-fPIC")
		end

		return result
	end

	function genie.snc.getcxxflags(cfg)
		local result = table.translate(cfg.flags, cxxflags)
		return result
	end



--
-- Returns a list of linker flags, based on the supplied configuration.
--

	function genie.snc.getldflags(cfg)
		local result = { }

		if not cfg.flags.Symbols then
			table.insert(result, "-s")
		end

		if cfg.kind == "SharedLib" then
			table.insert(result, "-shared")
			if not cfg.flags.NoImportLib then
				table.insert(result, '-Wl,--out-implib="' .. cfg.linktarget.fullpath .. '"')
			end
		end

		local platform = platforms[cfg.platform]
		table.insert(result, platform.flags)
		table.insert(result, platform.ldflags)

		return result
	end


--
-- Return a list of library search paths. Technically part of LDFLAGS but need to
-- be separated because of the way Visual Studio calls SNC for the PS3. See bug
-- #1729227 for background on why library paths must be split.
--

	function genie.snc.getlibdirflags(cfg)
		local result = { }
		for _, value in ipairs(genie.getlinks(cfg, "all", "directory")) do
			table.insert(result, '-L' .. _MAKE.esc(value))
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
	function genie.snc.getlibfiles(cfg)
		local result = {}
		return result
	end

	--
	-- This is poorly named: returns a list of linker flags for external
	-- (i.e. system, or non-sibling) libraries. See bug #1729227 for
	-- background on why the path must be split.
	--

	function genie.snc.getlinkflags(cfg)
		local result = {}
		for _, value in ipairs(genie.getlinks(cfg, "system", "name")) do
			table.insert(result, '-l' .. _MAKE.esc(value))
		end
		return result
	end



--
-- Decorate defines for the SNC command line.
--

	function genie.snc.getdefines(defines)
		local result = { }
		for _,def in ipairs(defines) do
			table.insert(result, '-D' .. def)
		end
		return result
	end



--
-- Decorate include file search paths for the SNC command line.
--

	function genie.snc.getincludedirs(includedirs)
		local result = { }
		for _,dir in ipairs(includedirs) do
			table.insert(result, "-I" .. _MAKE.esc(dir))
		end
		return result
	end
