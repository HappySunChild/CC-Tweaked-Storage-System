local numbers = {}

local abbreviations = { "K", "M", "B", "T", "Qa", "Qi" }

---@param number number
---@return string
function numbers.abbreviate(number)
	if number < 1000 then
		return tostring(number)
	end

	local index = math.floor(math.log10(number + 1) / 3)

	return string.format("%.1f%s", number / 10 ^ (index * 3), abbreviations[index])
end

return numbers
