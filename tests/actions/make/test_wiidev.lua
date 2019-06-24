--
-- tests/actions/make/test_wiidev.lua
-- Tests for Wii homebrew support in makefiles.
-- Copyright (c) 2011 Jason Perkins and the Premake project
--

	T.make_wiidev = { }
	local suite = T.make_wiidev
	local make = genie.make
	local cpp = genie.make.cpp

	local sln, prj, cfg

	function suite.setup()
		_ACTION = "gmake"

		sln = solution("MySolution")
		configurations { "Debug", "Release" }
		platforms { "WiiDev" }

		prj = project("MyProject")

		genie.bake.buildconfigs()
		cfg = genie.getconfig(prj, "Debug", "WiiDev")
	end


--
-- Make sure that the Wii-specific flags are passed to the tools.
--

	function suite.writesCorrectFlags()
		cpp.flags(cfg, genie.gcc)
		test.capture [[
  ALL_CPPFLAGS  += $(CPPFLAGS) -MMD -MP -I$(LIBOGC_INC) $(MACHDEP) -MP $(DEFINES) $(INCLUDES)
  ALL_CFLAGS    += $(CFLAGS) $(ALL_CPPFLAGS) $(ARCH)
  ALL_CXXFLAGS  += $(CXXFLAGS) $(ALL_CFLAGS)
  ALL_RESFLAGS  += $(RESFLAGS) $(DEFINES) $(INCLUDES)
  		]]
	end

	function suite.writesCorrectLinkFlags()
		cpp.linker(cfg, genie.gcc)
		test.capture [[
  ALL_LDFLAGS   += $(LDFLAGS) -s -L$(LIBOGC_LIB) $(MACHDEP)
  		]]
	end


--
-- Make sure the dev kit include is written to each Wii build configuration.
--

	function suite.writesIncludeBlock()
		make.settings(cfg, genie.gcc)
		test.capture [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules'
		]]
	end
