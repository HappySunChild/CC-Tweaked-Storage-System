local abbreviate = require("utility/abbreviate")
local getDisplayName = require("utility/getDisplayName")
local justify = require("utility/justify")
local truncate = require("utility/truncate")

local INDEX_FORMAT = "%2d. "
local COUNT_FORMAT = " |%5s"

---@class StorageDisplay.Configuration
---@field column_count integer
---@field max_rows integer

---@class StorageDisplay
---@field redirect term.Redirect
---@field configuration StorageDisplay.Configuration
local CLASS = {
	---@param self StorageDisplay
	---@param configuration StorageDisplay.Configuration
	reconfigure = function(self, configuration)
		self.configuration = configuration
	end,

	---@param self StorageDisplay
	---@param items peripheral.InventoryItem[]
	draw_item_cells = function(self, items)
		local screen = self.redirect
		local width, height = screen.getSize()

		local column_count = self.configuration.column_count
		local max_rows = math.min(self.configuration.max_rows, height)

		local column_width = math.floor(width / column_count) - 1

		screen.clear()

		for index, item in next, items do
			local column = math.floor((index - 1) / max_rows)
			local row = (index - 1) % max_rows + 1

			local x = column * (column_width + 1) + 1

			if column >= column_count then
				break
			end

			screen.setBackgroundColor((index + column) % 2 == 0 and colors.gray or colors.black)

			local item_index = INDEX_FORMAT:format(index)
			local item_count = COUNT_FORMAT:format(abbreviate(item.count))

			local name_width = column_width - #item_index - #item_count
			local item_name = justify(truncate(getDisplayName(item.name), name_width), name_width)

			screen.setCursorPos(x, row)
			screen.write(item_index .. item_name .. item_count .. "|")

			-- print(#item_index + #item_count + #item_name, column_width, name_width)
		end

		screen.setBackgroundColor(colors.black)
	end,
}
local METATABLE = { __index = CLASS }

---@param redirect term.Redirect
---@param configuration StorageDisplay.Configuration
---@return StorageDisplay
local function StorageDisplay(redirect, configuration)
	---@type StorageDisplay
	local new_storagedisplay = setmetatable({
		redirect = redirect,
		configuration = configuration,
	}, METATABLE)

	return new_storagedisplay
end

return StorageDisplay
