local completion  = require "cc.completion" ---@type cc.completion
local ui          = require "utility.ui"
local cache       = require "utility.cache"
local numbers     = require "utility.numbers"
local Theme       = require "theme"
local Config      = require "config"



Config:Load()

local TRUNCATE_TEXT = Config:Get('TruncateText')
local REFRESH_RATE = Config:Get('RefreshRate')
local SORT_MODE = Config:Get('SortOrder')

local TRUNCATE_LENGTH = 20
local COLUMN_WIDTH = 40



local monitor = peripheral.find('monitor') ---@type peripheral.Monitor
local speaker = peripheral.find('speaker') ---@type peripheral.Speaker
local outputInterface = peripheral.wrap('right') ---@type peripheral.Inventory
local systemInterface = peripheral.wrap('bottom') ---@type peripheral.Inventory


local IS_OLDER_VERSION = _VERSION == 'Lua 5.1'
local IS_AE2_SYSTEM = IS_OLDER_VERSION and systemInterface.listAvailableItems

local AE2_IGNORE_COUNT_CAP = 2 ^ 31 - 1
local DEFAULT_MAX_CAP = IS_AE2_SYSTEM and AE2_IGNORE_COUNT_CAP or 64


local function getSystemItems()
	if IS_AE2_SYSTEM then
		return systemInterface.listAvailableItems()
	end
	
	return systemInterface.list()
end

local function getSystemSize()
	if IS_OLDER_VERSION then
		return #getSystemItems()
	end
	
	return systemInterface.size()
end

local SYSTEM_ITEMS = getSystemItems()
local SYSTEM_SIZE = getSystemSize()


term.clear()
term.setCursorPos(1, 1)


monitor.clear()
monitor.setTextScale(0.5)
monitor.setCursorBlink(false)


local maxStackCache = cache.new()
local lastCountCache = cache.new()

if IS_OLDER_VERSION and systemInterface.getItemMeta then
	maxStackCache.fallback = function (slot)
		local meta = systemInterface.getItemMeta(slot)
		
		return meta.maxCount
	end
else
	maxStackCache.fallback = systemInterface.getItemLimit
end

---@param rawName string
---@return string
local function filterName(rawName)
	local name = rawName:match('.*:(.*)') ---@type string
	local filtered = name:gsub('_', ' ')
	
	return filtered
end

---@param targetName string
local function getSystemSlot(targetName)
	local searchName = targetName:lower()
	
	local found = {}
	
	for slotIndex, item in pairs(SYSTEM_ITEMS) do
		local name = filterName(item.name)
		local start = string.find(name, searchName, 1, true)
		
		if name == searchName then
			return slotIndex, item
		end
		
		if start then
			table.insert(found, {
				index = slotIndex,
				start = start
			})
		end
	end
	
	if #found <= 0 then
		return
	end
	
	table.sort(found, function (a, b)
		return a.start < b.start
	end)
	
	local chosenIndex = found[1].index
	
	return chosenIndex, SYSTEM_ITEMS[chosenIndex]
end

local function getSystemCount(itemName)
	local count = 0
	
	for _, item in pairs(SYSTEM_ITEMS) do
		if item.name == itemName then
			count = count + item.count
		end
	end
	
	return count
end


local function updateSystem()
	SYSTEM_ITEMS = getSystemItems()
	SYSTEM_SIZE = getSystemSize()
end


---@param count number
local function getDisplayCount(count)
	return string.format('%5s', numbers.abbreviate(count))
end

---@param rawName string
local function getDisplayName(rawName)
	local name = filterName(rawName)
	
	---@type string
	local formattedName = name:gsub('%s%l', function (char)
		return char:upper()
	end):gsub('^%l', function (char)
		return char:upper()
	end)
	
	if TRUNCATE_TEXT and #formattedName > TRUNCATE_LENGTH then
		formattedName = formattedName:sub(1, TRUNCATE_LENGTH - 3):gsub('%s*$', '') .. '...'
	end
	
	--namespace = namespace:sub(1, 1):upper() .. namespace:sub(2, 2)
	
	return formattedName
end




local function getSortedList()
	local list = {}
	
	for slot, item in pairs(SYSTEM_ITEMS) do
		local ok = item ~= nil
		
		if IS_AE2_SYSTEM then
			if (item.isCraftable and item.count == 0) or (item.count >= AE2_IGNORE_COUNT_CAP) then
				ok = false
			end
		end
		
		if ok then
			table.insert(list, {
				slot = slot,
				count = item.count,
				name = item.name
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



local function outputItems(itemName, amount)
	local slot, detail = getSystemSlot(itemName)
	
	if not (slot and detail) then
		return
	end
	
	local width = term.getSize()
	local totalTransfered = 0
	
	local _debounce = false
	
	repeat
		local transfered = systemInterface.pushItems('right', slot, amount - totalTransfered)
		
		totalTransfered = totalTransfered + transfered
		
		ui.progressbar(1, 4, width, totalTransfered / amount)
		
		if transfered == 0 then
			if amount > detail.count then
				updateSystem()
			
				slot, detail = getSystemSlot(itemName)
				
				if not (slot and detail) then
					break
				end
			elseif not _debounce then
				_debounce = true
				
				ui.push()
				term.setTextColor(colors.red)
				ui.writeCenter(3, 'Output is full!')
				ui.pop()
				
				speaker.playNote('bell', 0.5, 0)
			end
		elseif _debounce then
			_debounce = false
			term.setCursorPos(1, 4)
			term.clearLine()
		end
	until totalTransfered >= amount
	
	speaker.playNote("bell", 1, 18)
	
	return totalTransfered
end

local function insertItems()
	local width = term.getSize()
	
	local totalCount = 0
	local items = outputInterface.list()
	
	for _ in pairs(items) do
		totalCount = totalCount + 1
	end
	
	local count = 0
	
	for slot, item in pairs(items) do
		count = count + 1
		
		local alpha = count / totalCount
		ui.progressbar(1, 4, width, alpha)
		
		outputInterface.pushItems('bottom', slot, item.count)
	end
	
	speaker.playNote("bell", 1, 18)
end


local function requestTerminal()
	term.setCursorPos(1, 1)
	term.clear()
	
	local choice = ui.prompt('Request', nil, nil, function (partial)
		local choices = {
			'!insert'
		}
		
		for _, item in pairs(SYSTEM_ITEMS) do
			table.insert(choices, filterName(item.name))
		end
		
		table.sort(choices)
		
		return completion.choice(partial, choices)
	end)
	
	if choice == '!insert' then
		speaker.playNote('bell', 0.5, 6)
		
		insertItems()
		
		return
	end
	
	local slot, info = getSystemSlot(choice)
	
	if not (slot and info) then
		speaker.playNote('pling', 0.5, 22)
		
		printError(string.format('Could not find %q', choice))
		
		os.pullEvent('key')
		
		return
	end
	
	
	local detail = systemInterface.getItemDetail(slot)
	
	local systemCount = getSystemCount(info.name)
	local maxOutput = outputInterface.size() * detail.maxCount
	
	ui.writeCenter(6, string.format('Selected: %10s', getDisplayName(info.name)))
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
	
	outputItems(choice, amount)
end

local function displayMenu()
	monitor.setBackgroundColor(Theme:GetColor('Background'))
	monitor.clear()
	
	monitor.setCursorPos(1, 1)
	
	local width, height = monitor.getSize()
	local displayList = getSortedList()
	
	if #displayList == 0 then
		monitor.write('no items :(')
		
		return
	end
	
	local rows = height - 2
	local columns = math.floor(width / COLUMN_WIDTH)
	local cellCount = math.min(SYSTEM_SIZE, columns * rows)
	
	columns = math.ceil(cellCount / rows)
	
	if columns == 0 then
		monitor.write('monitor too small!')
		
		return
	end
	
	
	-- border drawing
	do
		ui.push(monitor)
		
		monitor.setTextColor(Theme:GetColor('Border'))
		
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
	
	
	local cellBackground = Theme:GetColor('Cell')
	local cellAltBackground = Theme:GetColor('CellAlt')
	local cellFullBackground = Theme:GetColor('CellFull')
	
	local increaseForeground = Theme:GetColor('IncreaseText')
	local decreaseForeground = Theme:GetColor('DecreaseText')
	
	for i = 1, math.min(cellCount, 100) do
		local item = displayList[i]
		
		if not item then
			break
		end
		
		ui.push(monitor)
		
		local slot = item.slot
		local currentCount = item.count
		
		local lastCount = lastCountCache:get(item.slot) or currentCount
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
		
		
		local max = maxStackCache:get(slot) or DEFAULT_MAX_CAP
		
		if currentCount >= max then
			monitor.setBackgroundColor(cellFullBackground)
		end
		
		
		lastCountCache:set(slot, currentCount)
		
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
end



local loadTheme = arg[1] or 'default'

Theme:LoadThemePalette(loadTheme, monitor)
Theme:LoadThemePalette(loadTheme, term)


Config:Save()

parallel.waitForAll(function ()
	if IS_AE2_SYSTEM then
		print('Terminal requesting is not compatible with a ae2 system!')
		
		return
	end
	
	
	while true do
		requestTerminal()
	end
end, function ()
	displayMenu()
	
	while true do
		local _, height = monitor.getSize()
		
		for i = 1, REFRESH_RATE do
			local text = string.format('Next refresh in %d seconds...', REFRESH_RATE - i)
			
			monitor.setCursorPos(1, height)
			monitor.write(text)
			
			sleep(1)
		end
		
		updateSystem()
		displayMenu()
	end
end)