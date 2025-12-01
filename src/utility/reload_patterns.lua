---@param autocrafter AutoCrafter
local function reload_patterns(autocrafter)
	local cur_dir = fs.getDir(shell.getRunningProgram())
	local pattern_dir = fs.combine(cur_dir, "patterns")

	if not fs.exists(pattern_dir) then
		return
	end

	for _, file in ipairs(fs.list(pattern_dir)) do
		local no_extension = file:gsub("%..*", "")

		-- loadfile instead of require to avoid caching
		local pattern_info = loadfile(fs.combine(pattern_dir, file), "t")() ---@type AutoCrafter.PatternInfo

		autocrafter:register_pattern(no_extension, pattern_info)
	end
end

return reload_patterns
