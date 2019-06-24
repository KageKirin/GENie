--
-- dotnet.lua
-- Interface for the C# compilers, all of which are flag compatible.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--


	genie.dotnet = { }
	genie.dotnet.namestyle = "windows"


--
-- Translation of GENie flags into CSC flags
--

	local flags =
	{
		FatalWarning   = "/warnaserror",
		Optimize       = "/optimize",
		OptimizeSize   = "/optimize",
		OptimizeSpeed  = "/optimize",
		Symbols        = "/debug",
		Unsafe         = "/unsafe"
	}


--
-- Return the default build action for a given file, based on the file extension.
--

	function genie.dotnet.getbuildaction(fcfg)
		local ext = path.getextension(fcfg.name):lower()
		if fcfg.buildaction == "Compile" or ext == ".cs" then
			return "Compile"
		elseif fcfg.buildaction == "Embed" or ext == ".resx" then
			return "EmbeddedResource"
		elseif fcfg.buildaction == "Copy" or ext == ".asax" or ext == ".aspx" then
			return "Content"
		else
			return "None"
		end
	end



--
-- Returns the compiler filename (they all use the same arguments)
--

	function genie.dotnet.getcompilervar(cfg)
		if (_OPTIONS.dotnet == "msnet") then
			return "csc"
		elseif (_OPTIONS.dotnet == "mono") then
			return "mcs"
		else
			return "cscc"
		end
	end



--
-- Returns a list of compiler flags, based on the supplied configuration.
--

	function genie.dotnet.getflags(cfg)
		local result = table.translate(cfg.flags, flags)
		return result
	end



--
-- Translates the GENie kind into the CSC kind string.
--

	function genie.dotnet.getkind(cfg)
		if (cfg.kind == "ConsoleApp") then
			return "Exe"
		elseif (cfg.kind == "WindowedApp") then
			return "WinExe"
		elseif (cfg.kind == "SharedLib") then
			return "Library"
		end
	end
