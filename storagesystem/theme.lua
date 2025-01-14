---@class Theme
---@field Background number
---@field Cell number
---@field CellAlt number
---@field CellFull number
---@field Text number
---@field IncreaseText number
---@field DecreaseText number
---@field Border number

local PALETTE_MAP = {
	Background = 'black',
	
	Cell = 'gray',
	CellAlt = 'lightGray',
	CellFull = 'red',
	
	Text = 'white',
	IncreaseText = 'green',
	DecreaseText = 'pink',
	Border = 'orange',
}

local Theme = {}

---@param themeName string
---@param screen term.Redirect
function Theme:LoadThemePalette(themeName, screen)
	themeName = themeName or 'default'
	
	local theme = require('themes.' .. themeName)
	
	for index, newColor in pairs(theme) do
		index = PALETTE_MAP[index] or index
		
		screen.setPaletteColor(colors[index], newColor)
	end
end

---@param index string
---@return integer
function Theme:GetColor(index)
	return colors[PALETTE_MAP[index]] or 1
end

return Theme