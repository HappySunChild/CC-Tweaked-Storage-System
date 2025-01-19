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



local theme = {}

function theme.getThemes()
	local path = fs.getDir(shell.getRunningProgram()) .. '/themes'
	local themes = fs.list(path)
	
	for index, file in ipairs(themes) do
		themes[index] = file:match('(.+)%.lua')
	end
	
	return themes
end


function theme.getInfo(themeName)
	themeName = themeName or 'default'
	
	return require('themes.' .. tostring(themeName):lower())
end

---@param themeName string
---@param screen term.Redirect
function theme.loadThemePalette(themeName, screen)
	local themeInfo = theme.getInfo(themeName)
	
	for index, newColor in pairs(themeInfo) do
		index = PALETTE_MAP[index] or index
		
		screen.setPaletteColor(colors[index], newColor)
	end
end

---@param index string
---@return integer
function theme.getColor(index)
	return colors[PALETTE_MAP[index]] or 1
end

---@param screen term.Redirect
function theme.clear(screen)
	for _, col in pairs(colors) do
		if type(col) == 'number' then
			local r, g, b = term.nativePaletteColor(col)
			
			screen.setPaletteColor(col, r, g, b)
		end
	end
end

return theme