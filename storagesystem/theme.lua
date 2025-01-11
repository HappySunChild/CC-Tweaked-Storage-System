local ThemeManager = {}

---@param themeName string
---@param screen Redirect
function ThemeManager:SetTheme(themeName, screen)
	local theme = require('themes.' .. themeName)
	
	for name, newColor in pairs(theme) do
		screen.setPaletteColor(colors[name], newColor)
	end
end

return ThemeManager