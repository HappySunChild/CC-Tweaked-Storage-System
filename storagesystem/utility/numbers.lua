local mathUtility = {}

local abbreviations = {'K', 'M', 'B', 'T', 'Qa', 'Qi'}

---@param number number
---@return string
function mathUtility.abbreviate(number)
	if number < 1000 then
		return tostring(number)
	end
	
	local index = math.floor(math.log(number + 1, 10) / 3)
	
	return string.format('%.1f%s', number / 10 ^ (index * 3), abbreviations[index])
end

return mathUtility