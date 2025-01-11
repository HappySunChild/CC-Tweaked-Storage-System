local mathUtility = {}

local abbreviations = {'K', 'M', 'B', 'T', 'Qa', 'Qi'}

---@param number number
---@param decimals integer
---@return string
function mathUtility.abbreviate(number, decimals)
	if number < 1000 then
		return tostring(number)
	end
	
	local index = math.floor(math.log(number + 1, 10) / 3)
	
	return string.format('%.1f%s', number / 10 ^ (index * 3), abbreviations[index])
end

return mathUtility