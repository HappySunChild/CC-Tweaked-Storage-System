local theme       = require('theme')
local config      = require('config')
local setup       = require('setup')
local system      = require('system')
local ui          = require('utility.ui')
local numbers     = require('utility.numbers')
local completion  = require('cc.completion')


local function find(tab, item)
	for i, v in next, tab do
		if v == item then
			return i
		end
	end
end

if setup.shouldRun() then
	setup.run()
end

if find(arg, '-c') then
	setup.configScreen()
end


local SORT_MODE = config:Get('SortOrder')
local USER_THEME = config:Get('UserTheme')
local REFRESH_RATE = config:Get('RefreshRate')
local TRUNCATE_TEXT = config:Get('TruncateText')
local TABS_ENABLED = config:Get('TabInventorySelect')


local TRUNCATE_LENGTH = 20
local COLUMN_WIDTH = 40
local CURRENT_INVENTORY = 0

local monitor = peripheral.find('monitor') ---@type peripheral.Monitor
local speaker = peripheral.find('speaker') ---@type peripheral.Speaker


term.clear()
term.setCursorPos(1, 1)


monitor.clear()
monitor.setTextScale(0.5)
monitor.setCursorBlink(false)

theme.clear(monitor)
theme.loadThemePalette(USER_THEME, monitor)
theme.loadThemePalette(USER_THEME, term)


system:InitiatePeripherals()


local LAST_COUNTS = {
	[0] = system:GetSystemItemCounts()
}


local function filterName(rawName)
	local name = rawName:match('[^:]*$') ---@type string
	local filtered = name:gsub('_', ' ')
	
	return filtered
end

local function getDisplayCount(count)
	return string.format('%5s', numbers.abbreviate(count))
end

local function getDisplayName(rawName, truncate)
	local name = filterName(rawName)
	
	---@type string
	local formattedName = name:gsub('%s%l', function (char)
		return char:upper()
	end):gsub('^%l', function (char)
		return char:upper()
	end)
	
	if truncate ~= false and TRUNCATE_TEXT and #formattedName > TRUNCATE_LENGTH then
		formattedName = formattedName:sub(1, TRUNCATE_LENGTH - 3):gsub('%s*$', '') .. '...'
	end
	
	return formattedName
end

local function getSortedList()
	local list = {}
	local items = {}
	
	if CURRENT_INVENTORY == 0 then
		items = system:GetSystemItems()
	else
		items = system:GetInventoryItems(system:GetInventory(CURRENT_INVENTORY))
	end
	
	for _, item in pairs(items) do
		local ok = item ~= nil
		
		if ok then
			table.insert(list, {
				count = item.count,
				name = system:GetItemName(item)
			})
		end
	end
	
	table.sort(list, function (a, b)
		if SORT_MODE == 'Desc' then
			if a.count == b.count then
				return a.name < b.name
			end
			
			return a.count > b.count
		elseif SORT_MODE == 'Asc' then
			if a.count == b.count then
				return a.name < b.name
			end
			
			return a.count < b.count
		end
		
		return false
	end)
	
	return list
end


local function requestTerminal()
	term.setCursorPos(1, 1)
	term.clear()
	
	local request = ui.prompt('Request', nil, nil, function (partial)
		local choices = {
			'!insert'
		}
		
		for _, item in pairs(system:GetSystemItems()) do
			table.insert(choices, filterName(item.name))
		end
		
		table.sort(choices)
		
		return completion.choice(partial, choices)
	end)
	
	if request == '!insert' then
		speaker.playNote('bell', 0.5, 6)
		
		system:PullItems()
		
		os.cancelAlarm(1)
		term.write('1')
		
		speaker.playNote('bell', 0.5, 18)
		
		return
	end
	
	local inventory, slot, item = system:FindSystemItem(request)
	
	if not (slot and item and item) then
		speaker.playNote('pling', 0.5, 22)
		
		printError(string.format('Could not find %q', request))
		
		os.pullEvent('key')
		
		return
	end
	
	local detail = inventory.getItemDetail(slot)
	local name = system:GetItemName(item)
	
	local systemCount = system:GetSystemCount(name)
	local maxOutput = system.BufferInventory.size() * detail.maxCount
	
	ui.writeCenter(6, string.format('Selected: %10s', getDisplayName(name, false)))
	ui.writeCenter(8, string.format('System Count: %6d', systemCount))
	ui.writeCenter(9, string.format('Max Output: %8d', maxOutput))
	
	term.setCursorPos(1, 2)
	
	speaker.playNote('bell', 0.5, 6)
	
	local requestAmount = ui.prompt('Amount')
	local amount = tonumber(requestAmount) or 64	
	
	if requestAmount == '*' then
		amount = math.min(maxOutput, systemCount)
	end
	
	speaker.playNote('bell', 0.5, 12)
	
	local success = system:PushItems(name, amount)
	
	if success then
		speaker.playNote('bell', 0.5, 24)
	end
end

local function displayMenu()
	if CURRENT_INVENTORY > #system.Inventories then
		CURRENT_INVENTORY = 0
	end
	
	monitor.setBackgroundColor(theme.getColor('Background'))
	monitor.clear()
	
	
	monitor.setCursorPos(1, 1)
	
	local width, height = monitor.getSize()
	local displayList = getSortedList()
	
	if #displayList == 0 then
		monitor.write('no items :(')
	end
	
	local rows = height - 2
	local columns = math.floor(width / COLUMN_WIDTH)
	local cellCount = math.min(system.SlotCount, columns * rows)
	
	columns = math.ceil(cellCount / rows)
	
	if columns == 0 then
		monitor.write('monitor too small!')
		
		return
	end
	
	
	-- border drawing
	do
		ui.push(monitor)
		
		monitor.setTextColor(theme.getColor('Border'))
		
		for x = 1, columns do
			for y = 1, rows do
				monitor.setCursorPos(x * COLUMN_WIDTH, y)
				monitor.write('|')
			end
		end
		
		local bottom = (string.rep('-', COLUMN_WIDTH - 1) .. '+'):rep(columns)
		
		
		monitor.setCursorPos(1, rows + 1)
		monitor.write(bottom)
		
		ui.pop(monitor)
	end
	
	
	local cellBackground = theme.getColor('Cell')
	local cellAltBackground = theme.getColor('CellAlt')
	
	local increaseForeground = theme.getColor('IncreaseText')
	local decreaseForeground = theme.getColor('DecreaseText')
	
	local lastCounts = LAST_COUNTS[CURRENT_INVENTORY]
	
	for i = 1, cellCount do
		local item = displayList[i]
		
		if not item then
			break
		end
		
		ui.push(monitor)
		
		local currentCount = item.count
		local lastCount = lastCounts[item.name] or 0 --currentCount --lastCountCache:get(item.slot) or currentCount
		
		
		local countDifference = currentCount - lastCount
		
		if currentCount > lastCount then
			monitor.setTextColor(increaseForeground)
		elseif currentCount < lastCount then
			monitor.setTextColor(decreaseForeground)
		end
		
		if i % 2 ~= 0 then
			monitor.setBackgroundColor(cellBackground)
		else
			monitor.setBackgroundColor(cellAltBackground)
		end
		
		--lastCountCache:set(slot, currentCount)
		
		local displayName = getDisplayName(item.name)
		local displayCount = getDisplayCount(currentCount)
		
		local text = string.format('%2d. %-20s | %s %+4d', i, displayName, displayCount, countDifference)
		text = text:sub(1, COLUMN_WIDTH - 1)
		
		local x = 1 + math.floor((i - 1) / rows) * COLUMN_WIDTH
		local y = (i - 1) % rows + 1
		
		monitor.setCursorPos(x, y)
		ui.wipeLine(COLUMN_WIDTH - 1, monitor)
		
		monitor.write(text)
		
		ui.pop(monitor)
	end
	
	
	monitor.setCursorPos(1, height)
	
	
	if TABS_ENABLED then
		local fgBlit = colors.toBlit(colors.white)
		
		local text = ''
		local bg = ''
		
		for index = 0, #system.Inventories do
			local color = cellBackground
			
			if index == CURRENT_INVENTORY then
				color = theme.getColor('CellFull')
			elseif index % 2 == 0 then
				color = cellAltBackground
			end
			
			local blit = colors.toBlit(color)
			local name = getDisplayName(system:GetInventoryName(index) or 'All Inventories')
			
			
			text = text .. name .. ' '
			bg = bg .. blit:rep(#name) .. colors.toBlit(colors.black)
		end
		
		monitor.blit(text, fgBlit:rep(#text), bg)
	else
		local name = getDisplayName(system:GetInventoryName(CURRENT_INVENTORY) or 'All Inventories')
		local text = string.format('%s [%d/%d]', getDisplayName(name), CURRENT_INVENTORY, #system.Inventories)
		
		monitor.setCursorPos(1, height)
		monitor.write(text)
	end
end



local function selectInventory(index)
	if index == CURRENT_INVENTORY then
		return
	end
	
	CURRENT_INVENTORY = index
	
	speaker.playSound('block.lever.click', 1, 2)
	
	displayMenu()
end





-- parallel functions


local function terminal()
	while true do
		requestTerminal()
	end
end

local function refresh()
	local function redraw()
		while true do
			os.pullEvent('system_updated')
			
			displayMenu()
		end
	end
	
	local function periodicUpdate()
		while true do
			LAST_COUNTS[0] = system:GetSystemItemCounts()
			
			for i, inventory in ipairs(system.Inventories) do
				LAST_COUNTS[i] = system:GetInventoryItemCounts(inventory)
			end
			
			system:Update()
			
			sleep(REFRESH_RATE)
		end
	end
	
	parallel.waitForAll(redraw, periodicUpdate)
end

local function modems()
	local function connect()
		while true do
			os.pullEvent('peripheral')
			
			system:InitiatePeripherals()
		end
	end
	
	local function disconnect()
		while true do
			os.pullEvent('peripheral_detach')
			
			system:InitiatePeripherals()
		end
	end
	
	parallel.waitForAll(connect, disconnect)
end

local function monitors()
	local function onResize()
		while true do
			os.pullEvent('monitor_resize')
			
			theme.loadThemePalette(USER_THEME, monitor)
			monitor.setTextScale(0.5)
			
			displayMenu()
		end
	end
	
	local function touch()
		while true do
			local _, _, cx, cy = os.pullEvent('monitor_touch')
			local _, height = monitor.getSize()
			
			local newIndex = (CURRENT_INVENTORY + 1) % (#system.Inventories + 1)
			
			if cy == height and TABS_ENABLED then
				local x = 0
				
				for index = 0, #system.Inventories do
					local name = getDisplayName(system:GetInventoryName(index) or 'All Inventories')
					local width = #name
					
					if cx > x and cx < x + width then
						newIndex = index
						
						break
					end
					
					x = x + width + 1
				end
			end
			
			selectInventory(newIndex)
		end
	end
	
	parallel.waitForAll(touch, onResize)
end



parallel.waitForAll(terminal, refresh, monitors, modems)