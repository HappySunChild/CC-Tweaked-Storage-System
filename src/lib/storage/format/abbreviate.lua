local SUFFIXES = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

---Converts the passed number into an abbreviate representation.
---@param number number
---@return string
local function abbreviate(number)
	if number < 1000 then
		return tostring(number)
	end

	local index = math.floor(math.log(number + 1, 10) / 3)
	local suffix = SUFFIXES[index]

	if suffix == nil then
		suffix = "!?"
	end

	return string.format("%.1f%s", number / 10 ^ (index * 3), suffix)
end

return abbreviate
