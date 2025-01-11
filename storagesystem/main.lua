local REFRESH_RATE = 5
local COLUMN_WIDTH = 40
local SORT_MODE = 'Desc'

local ui          = require "utility.ui"
local cache       = require "utility.cache"
local numbers     = require "utility.numbers"
local ProgressBar = require "utility.progressbar"
local ThemeManager       = require "theme"

local monitor = peripheral.find('monitor') ---@type Peripheral.Monitor
local speaker = peripheral.find('speaker') ---@type Peripheral.Speaker
local systemInterface = peripheral.wrap('bottom') ---@type Peripheral.Inventory

local IS_OLDER_VERSION = _VERSION == 'Lua 5.1'
local IS_AE2_SYSTEM = IS_OLDER_VERSION and systemInterface.listAvailableItems and systemInterface.getNodeEnergyAvailable

local AE2_IGNORE_COUNT_CAP = 2 ^ 31 - 1
local DEFAULT_MAX_CAP = IS_AE2_SYSTEM and AE2_IGNORE_COUNT_CAP or 64

local function getSystemItems()
	if IS_AE2_SYSTEM then
		return systemInterface.listAvailableItems()
	end
	
	return systemInterface.list()
end

local SYSTEM_ITEMS = getSystemItems()
local SYSTEM_SIZE = #SYSTEM_ITEMS


local theme = arg[1] or 'default'

ThemeManager:SetTheme(theme, monitor)
ThemeManager:SetTheme(theme, term)

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


---@param targetName string
local function findSystemIndex(targetName)
	local searchName = string.lower(targetName)
	
	local found = {}
	
	for slotIndex, item in pairs(SYSTEM_ITEMS) do
		local name = string.match(item.name, '.*:(.*)')
		local start = string.find(name, searchName, 1, true)
		
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



---@param count number
local function getDisplayCount(count)
	return string.format('%5s', numbers.abbreviate(count))
end

---@param rawName string
local function getDisplayName(rawName)
	local item = rawName:match('.*:(.*)')
	
	local formattedName = item:gsub('_(%l)', function (char)
		return ' ' .. char:upper()
	end):gsub('^%l', function (char)
		return char:upper()
	end)
	
	--namespace = namespace:sub(1, 1):upper() .. namespace:sub(2, 2)
	
	return formattedName
end




local function getSortedList()
	local list = {}
	
	for slot, item in pairs(SYSTEM_ITEMS) do
		local ok = item ~= nil
		
		if IS_AE2_SYSTEM and item.count >= AE2_IGNORE_COUNT_CAP then
			ok = false
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
		if a and b then
			if SORT_MODE == 'Desc' then
				return a.count > b.count
			elseif SORT_MODE == 'Asc' then
				return a.count < b.count
			end
		end
		
		return false
	end)
	
	return list
end

local function displayMenu()
	local width, height = monitor.getSize()
	local displayList = getSortedList()
	
	local rowCount = height - 2
	local columnCount = math.floor(width / COLUMN_WIDTH)
	
	if columnCount == 0 then
		monitor.setCursorPos(1, 1)
		monitor.write('monitor too small!')
		
		return
	end
	
	monitor.clear()
	
	ui.push(monitor)
	
	monitor.setTextColor(colors.orange)
	
	for x = 1, columnCount do
		for y = 1, rowCount do
			monitor.setCursorPos(x * COLUMN_WIDTH, y)
			monitor.write('|')
		end
	end
	
	local bottom = ''
	
	for _ = 1, columnCount do
		bottom = bottom .. string.rep('-', COLUMN_WIDTH - 1) .. '+'
	end
	
	monitor.setCursorPos(1, rowCount + 1)
	monitor.write(bottom)
	
	ui.pop(monitor)
	
	for i = 1, math.min(SYSTEM_SIZE, columnCount * rowCount, 100) do
		local item = displayList[i]
		
		if not item then
			break
		end
		
		local slot = item.slot
		local currentCount = item.count
		
		ui.push(monitor)
		
		local lastCount = lastCountCache:get(item.slot) or currentCount
		local countDifference = currentCount - lastCount
		
		if currentCount > lastCount then
			monitor.setTextColor(colors.green)
		elseif currentCount < lastCount then
			monitor.setTextColor(colors.pink)
		end
		
		if i % 2 == 0 then
			monitor.setBackgroundColor(colors.gray)
		else
			monitor.setBackgroundColor(colors.black)
		end
		
		
		local max = maxStackCache:get(slot) or DEFAULT_MAX_CAP
		
		if currentCount >= max then
			monitor.setBackgroundColor(colors.red)
		elseif currentCount >= max * 0.8 then
			--monitor.setBackgroundColor(colors.orange)
		end
		
		
		lastCountCache:set(slot, currentCount)
		
		local displayName = getDisplayName(item.name)
		local displayCount = getDisplayCount(currentCount)
		
		local text = string.format('%2d. %-20s | %s %+4d', i, displayName, displayCount, countDifference)
		
		local x = 1 + math.floor((i - 1) / rowCount) * COLUMN_WIDTH
		local y = (i - 1) % rowCount + 1
		
		monitor.setCursorPos(x, y)
		ui.wipeLine(COLUMN_WIDTH - 1, monitor)
		
		monitor.write(text)
		
		ui.pop(monitor)
	end
end


local function requestTerminal()
	term.setCursorPos(1, 1)
	term.clear()
	term.write('Item: ')
	
	local requestedItemName = read(nil, nil, function (partial)
		local list = {}
		
		for _, item in pairs(SYSTEM_ITEMS) do
			local name = string.match(item.name, '.*:(.*)')
			local _, start = name:find(partial)
			
			if start then
				table.insert(list, name:sub(start + 1))
			end
		end
		
		table.sort(list, function (a, b)
			return a < b
		end)
		
		return list
	end)
	
	local slot, details = findSystemIndex(requestedItemName)
	
	if not slot or not details then
		printError(string.format('Could not find %q', requestedItemName))
		
		os.pullEvent('key')
		
		return
	end
	
	ui.writeCenter(6, string.format('%q selected.', getDisplayName(details.name)), term)
	term.setCursorPos(1, 2)
	
	local stackSize = details.count
	
	term.write('Amount: ')
	
	local requestedAmount = math.min(tonumber(read()) or 64, stackSize)
	
	if slot then
		local debounce = false
		
		local bar = ProgressBar.new(1, 3, term.getSize())
		local totalTransfered = 0
		
		repeat
			local transfered = systemInterface.pushItems('right', slot, requestedAmount - totalTransfered)
			totalTransfered = totalTransfered + transfered
			
			bar:Update(totalTransfered / requestedAmount)
			
			if transfered == 0 and totalTransfered < requestedAmount then
				if not debounce then
					speaker.playNote("pling", 1, 1.5)
				end
				
				debounce = true
				
				term.setTextColor(colors.red)
				ui.writeCenter(3, 'Output is full!', term)
			else
				debounce = false
			end
		until totalTransfered >= requestedAmount
		
		speaker.playNote("bell", 1, 2)
		
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.black)
	end
end


parallel.waitForAll(function ()
	while not IS_AE2_SYSTEM do
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
		
		SYSTEM_ITEMS = getSystemItems()
		
		displayMenu()
	end
end)
