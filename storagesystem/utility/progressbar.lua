local ProgressBar = {}
local BarClass = {}

function ProgressBar.new(x, y, width)
	local newBar = setmetatable({
		X = x,
		Y = y,
		Width = width,
		Screen = term.current()
	}, {__index = BarClass})
	
	return newBar
end

function BarClass:Update(alpha)
	---@type Redirect
	local screen = self.Screen
	
	screen.setCursorPos(self.X, self.Y)
	
	local len = math.floor(alpha * self.Width)
	local invLen = math.ceil((1 - alpha) * self.Width)
	
	screen.setBackgroundColor(colors.white)
	screen.write(string.rep(' ', len))
	
	screen.setBackgroundColor(colors.gray)
	screen.write(string.rep(' ', invLen))
end

return ProgressBar