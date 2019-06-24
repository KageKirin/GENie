--
-- swift.lua
-- Provides Swift-specific configuration strings.
--


	genie.swift = { }


--
-- Set default tools
--

	genie.swift.swiftc   = "swiftc"
	genie.swift.swift    = "swift"
	genie.swift.cc       = "gcc"
	genie.swift.ar       = "ar"
	genie.swift.ld       = "ld"
	genie.swift.dsymutil = "dsymutil"


--
-- Translation of GENie flags into Swift flags
--

local swiftcflags =
{
	Symbols                   = "-g",                             -- Produce debug information
	DisableWarnings           = "--suppress-warnings",            -- Disable warnings
	FatalWarnings             = "--warnings-as-errors",           -- Treat warnings as fatal
	Optimize                  = "-O -whole-module-optimization",
	OptimizeSize              = "-O -whole-module-optimization",
	OptimizeSpeed             = "-Ounchecked -whole-module-optimization",
	MinimumWarnings           = "-minimum-warnings",
}

local swiftlinkflags = {
	StaticRuntime             = "-static-stdlib",
}

genie.swift.platforms = {
	Native = {
		swiftcflags    = "",
		swiftlinkflags = "",
	},
	x64 = {
		swiftcflags    = "",
		swiftlinkflags = "",
	}
}

local platforms = genie.swift.platforms

--
-- Returns a list of compiler flags, based on the supplied configuration.
--

function genie.swift.get_sdk_path(cfg)
	return string.trim(os.outputof("xcrun --show-sdk-path"))
end

function genie.swift.get_sdk_platform_path(cfg)
	return string.trim(os.outputof("xcrun --show-sdk-platform-path"))
end

function genie.swift.get_toolchain_path(cfg)
	return string.trim(os.outputof("xcode-select -p")) .. "/Toolchains/XcodeDefault.xctoolchain"
end

function genie.swift.gettarget(cfg)
	return "-target x86_64-apple-macosx10.11"
end

function genie.swift.getswiftcflags(cfg)
	local result = table.translate(cfg.flags, swiftcflags)
	table.insert(result, platforms[cfg.platform].swiftcflags)
	
	result = table.join(result, cfg.buildoptions_swift)
	
	if cfg.kind == "SharedLib" or cfg.kind == "StaticLib" then
		table.insert(result, "-parse-as-library")
	end
	
	table.insert(result, genie.swift.gettarget(cfg))
	
	return result
end

function genie.swift.getswiftlinkflags(cfg)
	local result = table.translate(cfg.flags, swiftlinkflags)
	table.insert(result, platforms[cfg.platform].swiftlinkflags)
	
	result = table.join(result, cfg.linkoptions_swift)
	
	if cfg.kind == "SharedLib" or cfg.kind == "StaticLib" then
		table.insert(result, "-emit-library")
	else
		table.insert(result, "-emit-executable")
	end
	
	table.insert(result, genie.swift.gettarget(cfg))
	
	return result
end

function genie.swift.getmodulemaps(cfg)
	local maps = {}
	if next(cfg.swiftmodulemaps) then
		for _, mod in ipairs(cfg.swiftmodulemaps) do
			table.insert(maps, string.format("-Xcc -fmodule-map-file=%s", mod))
		end
	end
	return maps
end

function genie.swift.getlibdirflags(cfg)
	return genie.gcc.getlibdirflags(cfg)
end

function genie.swift.getldflags(cfg)
	local result = { platforms[cfg.platform].ldflags }
	
	local links = genie.getlinks(cfg, "siblings", "basename")
	for _,v in ipairs(links) do
		if path.getextension(v) == ".framework" then
			table.insert(result, "-framework "..v)
		else
			table.insert(result, "-l"..v)
		end
	end
	
	return result
end

function genie.swift.getlinkflags(cfg)
	return genie.gcc.getlinkflags(cfg)
end

function genie.swift.getarchiveflags(cfg)
	return ""
end
