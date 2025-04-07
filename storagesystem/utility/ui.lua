local ui = {}

function ui.writeCenter(y, text)
	local width = term.getSize()

	local len = string.len(text)
	local x = math.floor(width / 2 - len / 2)

	term.setCursorPos(x, y)
	term.write(text)
end

---@param length number
---@param screen term.Redirect
function ui.wipeLine(length, screen)
	local width = screen.getSize()
	local x, y = screen.getCursorPos()

	length = length or width - x + 1

	screen.write(string.rep(" ", length))
	screen.setCursorPos(x, y)
end

local layers = {}

---@param screen term.Redirect?
function ui.push(screen)
	screen = screen or term

	-- compile style layer
	---@class StyleLayer
	local styleLayer = {
		background = screen.getBackgroundColor(),
		foreground = screen.getTextColor(),
	}

	if not layers[screen] then
		layers[screen] = {}
	end

	table.insert(layers[screen], 1, styleLayer)
end

---@param screen term.Redirect?
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

---@param text string
---@param ... any
function ui.prompt(text, ...)
	term.write(text .. ": ")

	return read(...)
end

function ui.promptBlocking(text, check, ...)
	local choice = nil

	repeat
		choice = ui.prompt(text, ...)
	until check(choice)

	return choice
end

function ui.progressbar(x, y, width, alpha)
	local len = math.floor(width * alpha)
	local eLen = width - len

	local textBlit = colors.toBlit(term.getTextColor())
	local fillBlit = colors.toBlit(colors.white)
	local emptyBlit = colors.toBlit(colors.lightGray)

	ui.push()

	term.setCursorPos(x, y)
	term.blit(string.rep(" ", len), textBlit:rep(len), fillBlit:rep(len))
	term.setCursorPos(x + len, y)
	term.blit(string.rep(" ", eLen), textBlit:rep(eLen), emptyBlit:rep(eLen))

	ui.pop()
end

return ui
