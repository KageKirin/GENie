--
-- project.lua
-- Functions for working with the project data.
-- Copyright (c) 2002 Jason Perkins and the Premake project
--

	genie.project = { }


--
-- Create a tree from a project's list of files, representing the filesystem hierarchy.
--
-- @param prj
--    The project containing the files to map.
-- @returns
--    A new tree object containing a corresponding filesystem hierarchy. The root node
--    contains a reference back to the original project: prj = tr.project.
--

	function genie.project.buildsourcetree(prj, allfiles)
		local tr = genie.tree.new(prj.name)
		tr.project = prj

		local isvpath

		local function onadd(node)
			node.isvpath = isvpath
		end

		for fcfg in genie.project.eachfile(prj, allfiles) do
			isvpath = (fcfg.name ~= fcfg.vpath)
			local node = genie.tree.add(tr, fcfg.vpath, onadd)
			node.cfg = fcfg
		end

		genie.tree.sort(tr)
		return tr
	end


--
-- Returns an iterator for a set of build configuration settings. If a platform is
-- specified, settings specific to that platform and build configuration pair are
-- returned.
--

	function genie.eachconfig(prj, platform)
		-- I probably have the project root config, rather than the actual project
		if prj.project then prj = prj.project end

		local cfgs = prj.solution.configurations
		local i = 0

		return function ()
			i = i + 1
			if i <= #cfgs then
				return genie.getconfig(prj, cfgs[i], platform)
			end
		end
	end



--
-- Iterator for a project's files; returns a file configuration object.
--

	function genie.project.eachfile(prj, allfiles)
		-- project root config contains the file config list
		if not prj.project then prj = genie.getconfig(prj) end
		local i = 0
		local t = iif(allfiles, prj.allfiles, prj.files)
		local c = iif(allfiles, prj.__allfileconfigs, prj.__fileconfigs)
		return function ()
			i = i + 1
			if (i <= #t) then
				local fcfg = c[t[i]]
				fcfg.vpath = genie.project.getvpath(prj, fcfg.name)
				return fcfg
			end
		end
	end



--
-- Apply XML escaping to a value.
--

	function genie.esc(value)
		if (type(value) == "table") then
			local result = { }
			for _,v in ipairs(value) do
				table.insert(result, genie.esc(v))
			end
			return result
		else
			value = value:gsub('&',  "&amp;")
			value = value:gsub('"',  "&quot;")
			value = value:gsub("'",  "&apos;")
			value = value:gsub('<',  "&lt;")
			value = value:gsub('>',  "&gt;")
			value = value:gsub('\r', "&#x0D;")
			value = value:gsub('\n', "&#x0A;")
			return value
		end
	end



--
-- Given a map of supported platform identifiers, filters the solution's list
-- of platforms to match. A map takes the form of a table like:
--
--  { x32 = "Win32", x64 = "x64" }
--
-- Only platforms that are listed in both the solution and the map will be
-- included in the results. An optional default platform may also be specified;
-- if the result set would otherwise be empty this platform will be used.
--

	function genie.filterplatforms(sln, map, default)
		local result = { }
		local keys = { }
		if sln.platforms then
			for _, p in ipairs(sln.platforms) do
				if map[p] and not table.contains(keys, map[p]) then
					table.insert(result, p)
					table.insert(keys, map[p])
				end
			end
		end

		if #result == 0 and default then
			table.insert(result, default)
		end

		return result
	end



--
-- Locate a project by name; case insensitive.
--

	function genie.findproject(name)
		for sln in genie.solution.each() do
			for prj in genie.solution.eachproject(sln) do
				if (prj.name == name) then
					return  prj
				end
			end
		end
	end



--
-- Locate a file in a project with a given extension; used to locate "special"
-- items such as Windows .def files.
--

	function genie.findfile(prj, extension)
		for _, fname in ipairs(prj.files) do
			if fname:endswith(extension) then return fname end
		end
	end



--
-- Retrieve a configuration for a given project/configuration pairing.
-- @param prj
--   The project to query.
-- @param cfgname
--   The target build configuration; only settings applicable to this configuration
--   will be returned. May be nil to retrieve project-wide settings.
-- @param pltname
--   The target platform; only settings applicable to this platform will be returned.
--   May be nil to retrieve platform-independent settings.
-- @returns
--   A configuration object containing all the settings for the given platform/build
--   configuration pair.
--

	function genie.getconfig(prj, cfgname, pltname)
		-- might have the root configuration, rather than the actual project
		prj = prj.project or prj

		-- if platform is not included in the solution, use general settings instead
		if pltname == "Native" or not table.contains(prj.solution.platforms or {}, pltname) then
			pltname = nil
		end

		local key = (cfgname or "")
		if pltname then key = key .. pltname end
		return prj.__configs[key]
	end



--
-- Build a name from a build configuration/platform pair. The short name
-- is good for makefiles or anywhere a user will have to type it in. The
-- long name is more readable.
--

	function genie.getconfigname(cfgname, platform, useshortname)
		if cfgname then
			local name = cfgname
			if platform and platform ~= "Native" then
				if useshortname then
					name = name .. genie.platforms[platform].cfgsuffix
				else
					name = name .. "|" .. platform
				end
			end
			return iif(useshortname, name:lower(), name)
		end
	end



--
-- Returns a list of sibling projects on which the specified project depends.
-- This is used to list dependencies within a solution or workspace. Must
-- consider all configurations because Visual Studio does not support per-config
-- project dependencies.
--
-- @param prj
--    The project to query.
-- @returns
--    A list of dependent projects, as an array of objects.
--

	function genie.getdependencies(prj)
		-- make sure I've got the project and not root config
		prj = prj.project or prj

		local results = { }
		for _, cfg in pairs(prj.__configs) do
			for _, link in ipairs(cfg.links) do
				local dep = genie.findproject(link)
				if dep and not table.contains(results, dep) then
					table.insert(results, dep)
				end
			end
		end

		return results
	end



--
-- Uses a pattern to format the basename of a file (i.e. without path).
--
-- @param prjname
--    A project name (string) to use.
-- @param pattern
--    A naming pattern. The sequence "%%" will be replaced by the
--    project name.
-- @returns
--    A filename (basename only) matching the specified pattern, without
--    path components.
--

	function genie.project.getbasename(prjname, pattern)
		return pattern:gsub("%%%%", prjname)
	end



--
-- Uses information from a project (or solution) to format a filename.
--
-- @param prj
--    A project or solution object with the file naming information.
-- @param pattern
--    A naming pattern. The sequence "%%" will be replaced by the
--    project name.
-- @returns
--    A filename matching the specified pattern, with a relative path
--    from the current directory to the project location.
--

	function genie.project.getfilename(prj, pattern)
		local fname = genie.project.getbasename(prj.name, pattern)
		fname = path.join(prj.location, fname)
		return path.getrelative(os.getcwd(), fname)
	end



--
-- Returns a list of link targets. Kind may be one of:
--   siblings     - linkable sibling projects
--   system       - system (non-sibling) libraries
--   dependencies - all sibling dependencies, including non-linkable
--   all          - return everything
--
-- Part may be one of:
--   name      - the decorated library name with no directory
--   basename  - the undecorated library name
--   directory - just the directory, no name
--   fullpath  - full path with decorated name
--   object    - return the project object of the dependency
--

 	function genie.getlinks(cfg, kind, part)
		-- if I'm building a list of link directories, include libdirs
		local result = iif (part == "directory" and kind == "all", cfg.libdirs, {})

		-- am I getting links for a configuration or a project?
		local cfgname = iif(cfg.name == cfg.project.name, "", cfg.name)

		-- how should files be named?
		local pathstyle = genie.getpathstyle(cfg)
		local namestyle = genie.getnamestyle(cfg)

		local function canlink(source, target)
			if (target.kind ~= "SharedLib" and target.kind ~= "StaticLib") then
				return false
			end
			if genie.iscppproject(source) then
				return genie.iscppproject(target)
			elseif genie.isdotnetproject(source) then
				return genie.isdotnetproject(target)
			elseif genie.isswiftproject(source) then
				return genie.isswiftproject(source) or genie.iscppproject(source)
			end
		end

		for _, link in ipairs(cfg.links) do
			local item

			-- is this a sibling project?
			local prj = genie.findproject(link)
			if prj and kind ~= "system" then

				local prjcfg = genie.getconfig(prj, cfgname, cfg.platform)
				if kind == "dependencies" or canlink(cfg, prjcfg) then
					if (part == "directory") then
						item = path.rebase(prjcfg.linktarget.directory, prjcfg.location, cfg.location)
					elseif (part == "basename") then
						item = prjcfg.linktarget.basename
					elseif (part == "fullpath") then
						item = path.rebase(prjcfg.linktarget.fullpath, prjcfg.location, cfg.location)
					elseif (part == "object") then
						item = prjcfg
					end
				end

			elseif not prj and (kind == "system" or kind == "all") then

				if (part == "directory") then
					item = path.getdirectory(link)
				elseif (part == "fullpath") then
					item = link
					if namestyle == "windows" then
						if genie.iscppproject(cfg) then
							item = item .. ".lib"
						elseif genie.isdotnetproject(cfg) then
							item = item .. ".dll"
						end
					end
				elseif part == "name" then
					item = path.getname(link)
				elseif part == "basename" then
					item = path.getbasename(link)
				else
					item = link
				end

				if item:find("/", nil, true) then
					item = path.getrelative(cfg.project.location, item)
				end

			end

			if item then
				if pathstyle == "windows" and part ~= "object" then
					item = path.translate(item, "\\")
				end
				if not table.contains(result, item) then
					table.insert(result, item)
				end
			end
		end

		return result
	end



--
-- Gets the name style for a configuration, indicating what kind of prefix,
-- extensions, etc. should be used in target file names.
--
-- @param cfg
--    The configuration to check.
-- @returns
--    The target naming style, one of "windows", "posix", or "PS3".
--

	function genie.getnamestyle(cfg)
		return genie.platforms[cfg.platform].namestyle or genie.gettool(cfg).namestyle or "posix"
	end



--
-- Gets the path style for a configuration, indicating what kind of path separator
-- should be used in target file names.
--
-- @param cfg
--    The configuration to check.
-- @returns
--    The target path style, one of "windows" or "posix".
--

	function genie.getpathstyle(cfg)
		if genie.action.current().os == "windows" then
			return "windows"
		else
			return "posix"
		end
	end


--
-- Assembles a target for a particular tool/system/configuration.
--
-- @param cfg
--    The configuration to be targeted.
-- @param direction
--    One of 'build' for the build target, or 'link' for the linking target.
-- @param pathstyle
--    The path format, one of "windows" or "posix". This comes from the current
--    action: Visual Studio uses "windows", GMake uses "posix", etc.
-- @param namestyle
--    The file naming style, one of "windows" or "posix". This comes from the
--    current tool: GCC uses "posix", MSC uses "windows", etc.
-- @param system
--    The target operating system, which can modify the naming style. For example,
--    shared libraries on Mac OS X use a ".dylib" extension.
-- @returns
--    An object with these fields:
--      basename   - the target with no directory or file extension
--      name       - the target name and extension, with no directory
--      directory  - relative path to the target, with no file name
--      prefix     - the file name prefix
--      suffix     - the file name suffix
--      fullpath   - directory, name, and extension
--      bundlepath - the relative path and file name of the bundle
--

	function genie.gettarget(cfg, direction, pathstyle, namestyle, system)
		if system == "bsd" then
			system = "linux"
		end

		-- Fix things up based on the current system
		local kind = cfg.kind
		if genie.iscppproject(cfg) then
			-- On Windows, shared libraries link against a static import library
			if (namestyle == "windows" or system == "windows")
				and kind == "SharedLib" and direction == "link"
				and not cfg.flags.NoImportLib
			then
				kind = "StaticLib"
			end

			-- Posix name conventions only apply to static libs on windows (by user request)
			if namestyle == "posix" and system == "windows" and kind ~= "StaticLib" then
				namestyle = "windows"
			end
		end

		-- Initialize the target components
		local field   = "build"
		if direction == "link" and cfg.kind == "SharedLib" then
			field = "implib"
		end

		local name    = cfg[field.."name"] or cfg.targetname or cfg.project.name
		local dir     = cfg[field.."dir"] or cfg.targetdir or path.getrelative(cfg.location, cfg.basedir)
		local subdir  = cfg[field.."subdir"] or cfg.targetsubdir or "."
		local prefix  = ""
		local suffix  = ""
		local ext     = ""
		local bundlepath, bundlename

		-- targetpath/targetsubdir/bundlepath/prefix..name..suffix..ext

		dir = path.join(dir, subdir)


		if namestyle == "windows" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				ext = ".exe"
			elseif kind == "SharedLib" then
				ext = ".dll"
			elseif kind == "StaticLib" then
				ext = ".lib"
			end
		elseif namestyle == "posix" then
			if kind == "WindowedApp" and system == "macosx" and not cfg.options.SkipBundling then
				bundlename = name .. ".app"
				bundlepath = path.join(dir, bundlename)
				dir = path.join(bundlepath, "Contents/MacOS")
			elseif (kind == "ConsoleApp" or kind == "WindowedApp") and system == "os2" then
				ext = ".exe"
			elseif kind == "SharedLib" then
				prefix = "lib"
				ext = iif(system == "macosx", ".dylib", ".so")
			elseif kind == "StaticLib" then
				prefix = "lib"
				ext = ".a"
			end
		elseif namestyle == "PS3" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				ext = ".elf"
			elseif kind == "StaticLib" then
				prefix = "lib"
				ext = ".a"
			end
		elseif namestyle == "Orbis" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				ext = ".elf"
			elseif kind == "StaticLib" then
				prefix = "lib"
				ext = ".a"
			elseif kind == "SharedLib" then
				ext = ".prx"
			end
		elseif namestyle == "TegraAndroid" then
			-- the .so->.apk happens later for Application types
			if kind == "ConsoleApp" or kind == "WindowedApp" or kind == "SharedLib" then
				prefix = "lib"
				ext = ".so"
			elseif kind == "StaticLib" then
				prefix = "lib"
				ext = ".a"
			end
		elseif namestyle == "NX" then
			-- NOTE: it would be cleaner to just output $(TargetExt) for all cases, but
			-- there is logic elsewhere that assumes a '.' to be present in target name
			-- such that it can reverse engineer the extension set here.
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				ext = ".nspd_root"
			elseif kind == "StaticLib" then
				ext = ".a"
			elseif kind == "SharedLib" then
				ext = ".nro"
			end
		elseif namestyle == "Emscripten" then
			if kind == "ConsoleApp" or kind == "WindowedApp" then
				ext = ".html"
			elseif kind == "StaticLib" then
				ext = ".bc"
			elseif kind == "SharedLib" then
				ext = ".js"
			end
		end

		prefix = cfg[field.."prefix"] or cfg.targetprefix or prefix
		suffix = cfg[field.."suffix"] or cfg.targetsuffix or suffix
		ext    = cfg[field.."extension"] or cfg.targetextension or ext

		-- build the results object
		local result = { }
		result.basename     = name .. suffix
		result.name         = prefix .. name .. suffix .. ext
		result.directory    = dir
		result.subdirectory = subdir
		result.prefix       = prefix
		result.suffix       = suffix
		result.fullpath     = path.join(result.directory, result.name)
		result.bundlepath   = bundlepath or result.fullpath

		if pathstyle == "windows" then
			result.directory    = path.translate(result.directory, "\\")
			result.subdirectory = path.translate(result.subdirectory, "\\")
			result.fullpath     = path.translate(result.fullpath,  "\\")
		end

		return result
	end


--
-- Return the appropriate tool interface, based on the target language and
-- any relevant command-line options.
--

	function genie.gettool(cfg)
		if genie.iscppproject(cfg) then
			if _OPTIONS.cc then
				return genie[_OPTIONS.cc]
			end
			local action = genie.action.current()
			if action.valid_tools then
				return genie[action.valid_tools.cc[1]]
			end
			return genie.gcc
		elseif genie.isdotnetproject(cfg) then
			return genie.dotnet
		elseif genie.isswiftproject(cfg) then
			return genie.swift
		else
			return genie.valac
		end
	end



--
-- Given a source file path, return a corresponding virtual path based on
-- the vpath entries in the project. If no matching vpath entry is found,
-- the original path is returned.
--

	function genie.project.getvpath(prj, abspath)
		-- If there is no match, the result is the original filename
		local vpath = abspath

		-- The file's name must be maintained in the resulting path; use these
		-- to make sure I don't cut off too much

		local fname = path.getname(abspath)
		local max = abspath:len() - fname:len()
        
        -- First check for an exact match from the inverse vpaths
        if prj.inversevpaths and prj.inversevpaths[abspath] then
            return path.join(prj.inversevpaths[abspath], fname)
        end

		-- Look for matching patterns
        local matches = {}
		for replacement, patterns in pairs(prj.vpaths or {}) do
			for _, pattern in ipairs(patterns) do
				local i = abspath:find(path.wildcards(pattern))
				if i == 1 then

					-- Trim out the part of the name that matched the pattern; what's
					-- left is the part that gets appended to the replacement to make
					-- the virtual path. So a pattern like "src/**.h" matching the
					-- file src/include/hello.h, I want to trim out the src/ part,
					-- leaving include/hello.h.

					-- Find out where the wildcard appears in the match. If there is
					-- no wildcard, the match includes the entire pattern

					i = pattern:find("*", 1, true) or (pattern:len() + 1)

					-- Trim, taking care to keep the actual file name intact.

					local leaf
					if i < max then
						leaf = abspath:sub(i)
					else
						leaf = fname
					end

					if leaf:startswith("/") then
						leaf = leaf:sub(2)
					end

					-- check for (and remove) stars in the replacement pattern.
					-- If there are none, then trim all path info from the leaf
					-- and use just the filename in the replacement (stars should
					-- really only appear at the end; I'm cheating here)

					local stem = ""
					if replacement:len() > 0 then
						stem, stars = replacement:gsub("%*", "")
						if stars == 0 then
							leaf = path.getname(leaf)
						end
					else
						leaf = path.getname(leaf)
					end

					table.insert(matches, path.join(stem, leaf))
				end
			end
		end
        
        if #matches > 0 then
            -- for the sake of determinism, return the first alphabetically
            table.sort(matches)
            vpath = matches[1]
        end

		return path.trimdots(vpath)
	end


--
-- Returns true if the solution contains at least one C/C++ project.
--

	function genie.hascppproject(sln)
		for prj in genie.solution.eachproject(sln) do
			if genie.iscppproject(prj) then
				return true
			end
		end
	end



--
-- Returns true if the solution contains at least one .NET project.
--

	function genie.hasdotnetproject(sln)
		for prj in genie.solution.eachproject(sln) do
			if genie.isdotnetproject(prj) then
				return true
			end
		end
	end



--
-- Returns true if the project use the C language.
--

	function genie.project.iscproject(prj)
		return prj.language == "C"
	end


--
-- Returns true if the project uses a C/C++ language.
--

	function genie.iscppproject(prj)
		return (prj.language == "C" or prj.language == "C++")
	end



--
-- Returns true if the project uses a .NET language.
--

	function genie.isdotnetproject(prj)
		return (prj.language == "C#")
	end

--
-- Returns true if the project uses the Vala language.
--

	function genie.isvalaproject(prj)
		return (prj.language == "Vala")
	end

--
-- Returns true if the project uses the Swift language.
--

	function genie.isswiftproject(prj)
		return (prj.language == "Swift")
	end
