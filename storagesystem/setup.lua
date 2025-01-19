local config     = require('config')
local theme      = require('theme')
local ui         = require('utility.ui')
local completion = require('cc.completion')

local themeList = theme.getThemes()
local setup = {}

function setup.shouldRun()
	local shouldRun = not config:Load()
	
	local bufferInventory = config:Get('BufferInventory')
	if not peripheral.isPresent(bufferInventory) then
		shouldRun = true
	end
	
	return shouldRun
end

function setup.run()
	term.clear()
	
	ui.writeCenter(1, 'First Time Setup')
	
	term.setCursorPos(1, 3)
	
	local userTheme = ui.promptBlocking('Theme', function (choice)
		local success = pcall(theme.getInfo, choice)
		
		if not success then
			printError('Invalid theme!')
			
			term.setCursorPos(1, 3)
			term.clearLine()
		end
		
		return success
	end, nil, nil, function (partial)
		local choices = completion.choice(partial, themeList)
		
		table.sort(choices, function (a, b)
			if a == 'default' then
				return true
			end
			
			return a < b
		end)
		
		return choices
	end)
	
	theme.loadThemePalette(userTheme, term)
	config:Set('UserTheme', userTheme)
	
	term.setCursorPos(1, 4)
	term.clearLine()
	
	local inventory = ui.promptBlocking('Buffer Inventory', function (choice)
		local success = peripheral.isPresent(choice) and peripheral.hasType(peripheral.wrap(choice), 'inventory')
		
		if not success then
			printError('Invalid peripheral!')
			
			term.setCursorPos(1, 4)
			term.clearLine()
			
			return false
		end
		
		return success
	end, nil, nil, function (partial)
		local choices = completion.peripheral(partial)
		
		return choices
	end)
	
	config:Set('BufferInventory', inventory)
	config:Save()
end

return setup