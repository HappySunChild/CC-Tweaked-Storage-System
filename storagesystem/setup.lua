local config     = require('config')
local theme      = require('theme')
local ui         = require('utility.ui')
local completion = require('cc.completion')

local themeList = theme.getThemes()
local setup = {}

local function find(tab, item)
	for i, v in next, tab do
		if v == item then
			return i
		end
	end
end


function setup.shouldRun()
	local shouldRun = not config:Load()
	
	if find(arg, '-s') then
		return true
	end
	
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


local configScreen = {
	'Theme',
	'Sort Order',
	'Refresh Rate',
	'Inventory Tabs',
	'Save and Exit'
}

local configIndexMap = {
	'UserTheme',
	'SortOrder',
	'RefreshRate',
	'TabInventorySelect'
}

local configOptions = {
	themeList,
	{'Asc', 'Desc'},
	function ()
		term.clear()
		term.setCursorPos(1, 1)
		
		return tonumber(ui.promptBlocking('Refresh Rate', function (choice)
			return tonumber(choice) ~= nil
		end))
	end,
	{true, false},
}

function setup.configScreen()
	local current = 1
	
	while true do
		term.clear()
		ui.writeCenter(1, 'Config Screen')
		
		for i, text in ipairs(configScreen) do
			local index = configIndexMap[i]
			
			if i == current then
				text = '> ' .. text
			end
			
			term.setCursorPos(10, i + 3)
			term.write(text)
			
			if index then
				term.setCursorPos(30, i + 3)
				term.write(string.format('%q', config:Get(index)))
			end
		end
		
		local _, key = os.pullEvent('key')
		
		if key == keys.down then
			current = math.min(current + 1, #configScreen)
		elseif key == keys.up then
			current = math.max(current - 1, 1)
		elseif key == keys.enter then
			if current == 5 then
				config:Save()
				
				break
			end
			
			local index = configIndexMap[current]
			local options = configOptions[current]
			
			local newValue = config:Get(index)
			
			if type(options) == 'function' then
				newValue = options()
			else
				local currentIndex = find(options, newValue) or 0
				local val = options[currentIndex + 1]
				
				if val == nil then
					val = options[1]
				end
				
				newValue = val
			end
			
			config:Set(index, newValue)
		end
	end
end

return setup