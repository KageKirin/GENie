--
-- option.lua
-- Work with the list of registered options.
-- Copyright (c) 2002-2009 Jason Perkins and the Premake project
--

	genie.option = { }


--
-- The list of registered options.
--

	genie.option.list = { }


--
-- Register a new option.
--
-- @param opt
--    The new option object.
--

	function genie.option.add(opt)
		-- some sanity checking
		local missing
		for _, field in ipairs({ "description", "trigger" }) do
			if (not opt[field]) then
				missing = field
			end
		end

		if (missing) then
			error("option needs a " .. missing, 3)
		end

		-- add it to the master list
		genie.option.list[opt.trigger] = opt
	end


--
-- Retrieve an option by name.
--
-- @param name
--    The name of the option to retrieve.
-- @returns
--    The requested option, or nil if the option does not exist.
--

	function genie.option.get(name)
		return genie.option.list[name]
	end


--
-- Iterator for the list of options.
--

	function genie.option.each()
		-- sort the list by trigger
		local keys = { }
		for _, option in pairs(genie.option.list) do
			table.insert(keys, option.trigger)
		end
		table.sort(keys)

		local i = 0
		return function()
			i = i + 1
			return genie.option.list[keys[i]]
		end
	end


--
-- Validate a list of user supplied key/value pairs against the list of registered options.
--
-- @param values
--    The list of user supplied key/value pairs.
-- @returns
---   True if the list of pairs are valid, false and an error message otherwise.
--

	function genie.option.validate(values)
		for key, value in pairs(values) do
			-- does this option exist
			local opt = genie.option.get(key)
			if (not opt) then
				return false, "invalid option '" .. key .. "'"
			end

			-- does it need a value?
			if (opt.value and value == "") then
				return false, "no value specified for option '" .. key .. "'"
			end

			-- is the value allowed?
			if opt.allowed then
				local found = false
				for _, match in ipairs(opt.allowed) do
					if match[1] == value then
						found = true
						break
					end
				end
				if not found then
					return false, string.format("invalid value '%s' for option '%s'", value, key)
				end
			end
		end
		return true
	end
