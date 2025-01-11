local ui = {}

---@param screen Redirect
function ui.writeCenter(y, text, screen)
	local width = screen.getSize()
	
	local len = string.len(text)
	local x = math.floor(width / 2 - len / 2)
	
	screen.setCursorPos(x, y)
	screen.write(text)
end

---@param length integer?
---@param screen Redirect
function ui.wipeLine(length, screen)
	local width = screen.getSize()
	local x, y = screen.getCursorPos()
	
	length = length or width - x + 1
	
	screen.write(string.rep(' ', length))
	screen.setCursorPos(x, y)
end

local layers = {}

---@param screen Redirect?
function ui.push(screen)
	screen = screen or term
	
	-- compile style layer
	---@class StyleLayer
	local styleLayer = {
		background = screen.getBackgroundColor(),
		foreground = screen.getTextColor()
	}
	
	if not layers[screen] then
		layers[screen] = {}
	end
	
	table.insert(layers[screen], 1, styleLayer)
end

---@param screen Redirect?
function ui.pop(screen)
	screen = screen or term
	
	if not layers[screen] then
		return
	end
	
	---@type StyleLayer?
	local styleLayer = table.remove(layers[screen], 1)
	
	if not styleLayer then
		return
	end
	
	-- apply style layer
	screen.setTextColor(styleLayer.foreground)
	screen.setBackgroundColor(styleLayer.background)
end

return ui