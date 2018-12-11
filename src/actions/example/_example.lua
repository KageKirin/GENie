-- Define a namespace for my new action. The second line defines an alias that I
-- can use in this file, saving myself some typing. It will not be visible outside
-- of this file (though I can always define it again).

	premake.example = { }
	local example = premake.example

	
-- The description of the action. Note that only the first three fields are required;
-- you can remove any of the additional fields that are not required by your action.

	newaction 
	{
		-- The trigger is what needs to be typed on the command line to cause 
		-- this action this run (premake4 example)
		trigger = "example",
		
		-- The short name is used when this toolset name needs to be shown to
		-- the user, such as in status or error messages
		shortname = "Super Studio 3000",
		
		-- The description is shown in the help text (premake4 /help)
		description = "An example action that prints simple text files",

		-- Some actions imply a particular operating system: Visual Studio only
		-- runs on Windows, and Xcode only on Mac OS X. If this is the case,
		-- uncomment this line and set it to one of "windows", "linux" or "macosx".
		-- Otherwise, this action will target the current operating system.
		-- os = "macosx",

		-- Which kinds of targets this action supports; remove those you don't.
		valid_kinds = { "ConsoleApp", "WindowedApp", "StaticLib", "SharedLib", "Bundle", "Framework", "StaticFramework" },

		-- Which programming languages this actions supports; remove those you don't.
		valid_languages = { "C", "C++", "C#" },

		-- Which compiler sets this action supports; remove those you don't. The set
		-- is specified with the /cc and /dotnet command-line options. You can find
		-- the tool interfaces at src/tools.
		valid_tools     = {
			cc     = { "msc", "gcc", "ow" },
			dotnet = { "mono", "msnet", "pnet" },
		},

		
		-- This function is called during state validation. If your action has some
		-- special requirements you can check them here and error if necessary.
		
		
		oncheckproject = function(prj)
			-- if this_project_is_no_good(prj) then
			--    error("Project " .. prj.name .. " is no good", 0)
			-- end
		end,
		

		-- These functions will get called for each solution and project. The function
		-- premake.generate() creates a file for you in the correct place, taking into
		-- account any location information specified in the script. The sequence "%%"
		-- will be replaced by the solution/project name. The last parameter is the 
		-- function that will actually do the work of generating the file contents.

		onsolution = function(sln)
			premake.generate(sln, "%%.sln.txt", premake.example.solution)
		end,

		onproject = function(prj)
			if premake.isdotnetproject(prj) then
				premake.generate(prj, "%%.csprj.txt", premake.example.project)
			else
				premake.generate(prj, "%%.cprj.txt", premake.example.project)
			end
		end,


		-- These functions are called for each solution, project, and target as part
		-- of the "clean" action. They should remove any files generated by the tools.
		-- premake.clean.file() and premake.clean.directory() are convenience functions
		-- that use the same pattern matching as premake.generate() above.

		oncleansolution = function(sln)
			premake.clean.file(sln, "%%.sln.txt")
		end,
		
		oncleanproject  = function(prj)
			if premake.isdotnetproject(prj) then
				premake.clean.file(prj, "%%.csprj.txt")
			else
				premake.clean.file(prj, "%%.cprj.txt")
			end
		end,
		
		oncleantarget   = function(trg)
			-- 'trg' is the path and base name of the target being cleaned,
			-- like 'bin/debug/MyApplication'. So you might do something like:
			-- os.remove(trg .. ".exe")
		end,
	}

