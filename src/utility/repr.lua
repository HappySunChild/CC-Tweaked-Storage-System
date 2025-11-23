---@class ReprSettings
---@field include_metatable? boolean

---@param display_pairs any
---@param depth number
---@return string
local function renderDisplayPairs(display_pairs, depth)
	if #display_pairs == 0 then
		return "{}"
	end

	local outer_indent = string.rep("\t", depth)
	local inner_indent = string.rep("\t", depth + 1)

	local lines = { "{" }

	for _, pair in next, display_pairs do
		table.insert(lines, string.format("%s[%s] = %s,", inner_indent, pair.key, pair.value))
	end

	table.insert(lines, outer_indent .. "}")

	return table.concat(lines, "\n")
end

---Returns the Lua representation of the passed in value.
---@param repr_value any
---@param settings? ReprSettings
---@return string
local function repr(repr_value, settings)
	local value_type = type(repr_value)

	if value_type == "string" then
		local str = repr_value

		return string.format('"%s"', str)
	elseif value_type == "function" then
		local func = repr_value
		local info = debug.getinfo(func, "nu")

		local display_args = {}

		for i = 1, info.nparams do
			table.insert(display_args, string.format("a%d", i - 1))
		end

		if info.isvararg then
			table.insert(display_args, "...")
		end

		return string.format("function %s(%s)", info.name or "", table.concat(display_args, ", "))
	elseif value_type == "table" then
		local active = {}

		local function recursive(target, depth)
			if type(target) ~= "table" then
				return repr(target)
			end

			if active[target] ~= nil then
				return string.format("[ RECURSIVE +%d ]", depth - active[target] - 1)
			end

			local display_pairs = {}

			active[target] = depth

			for key, value in next, target do
				table.insert(display_pairs, {
					key = recursive(key, depth + 1),
					value = recursive(value, depth + 1),
				})
			end

			table.sort(display_pairs, function(a, b)
				return a.key < b.key
			end)

			local output = renderDisplayPairs(display_pairs, depth)

			if settings ~= nil and settings.include_metatable then
				local metatable = getmetatable(target)

				if metatable then
					output = string.format("setmetatable(%s, %s)", output, recursive(metatable, depth))
				end
			end

			active[target] = nil

			return output
		end

		return recursive(repr_value, 0)
	end

	return tostring(repr_value)
end

return repr
