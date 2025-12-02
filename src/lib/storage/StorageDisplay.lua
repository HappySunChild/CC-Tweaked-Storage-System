local abbreviate = require("lib/storage/format/abbreviate")
local format_name = require("lib/storage/format/format_name")
local justify = require("lib/storage/format/justify")
local paint = require("lib/storage/format/paint")
local truncate = require("lib/storage/format/truncate")

local INDEX_FORMAT = "%d. "

---@class StorageDisplay.Configuration
---@field column_count integer
---@field index_justification integer
---@field cell_background_color integer?
---@field cell_alt_background_color integer?
---@field index_text_color integer?
---@field name_text_color integer?
---@field count_text_color integer?

---@class StorageDisplay
---@field redirect term.Redirect
---@field config StorageDisplay.Configuration
local CLASS = {
	---@param self StorageDisplay
	---@param configuration StorageDisplay.Configuration
	reconfigure = function(self, configuration)
		self.config = configuration
	end,

	---@param self StorageDisplay
	---@param items peripheral.InventoryItem[]
	draw_item_cells = function(self, items)
		local screen = self.redirect
		local width, height = screen.getSize()

		local config = self.config

		local column_count = config.column_count

		local index_blit = colors.toBlit(config.index_text_color or colors.lightBlue)
		local name_blit = colors.toBlit(config.name_text_color or colors.white)
		local count_blit = colors.toBlit(config.count_text_color or colors.pink)
		local bg_blit = colors.toBlit(config.cell_background_color or colors.black)
		local bg_alt_blit = colors.toBlit(config.cell_alt_background_color or colors.gray)

		local column_width = math.floor(width / column_count) - 1
		local extra_width = (width % column_count) + 1

		screen.clear()

		for index, item in next, items do
			local column = math.floor((index - 1) / height)
			local row = (index - 1) % height + 1

			local x = column * (column_width + 1) + 1

			if column >= column_count then
				break
			end

			local background_blit = (row + column) % 2 == 0 and bg_alt_blit or bg_blit

			local item_index = justify(INDEX_FORMAT:format(index), -config.index_justification)
			local item_count = " " .. abbreviate(item.count)

			local name_width = column_width - #item_index - #item_count

			if column + 1 >= column_count then
				name_width = name_width + extra_width -- make the edge a little longer if there's an edge
			end

			local item_name = justify(truncate(format_name(item.name), name_width), name_width)

			screen.setCursorPos(x, row)
			screen.blit(paint(item_index, index_blit, background_blit))
			screen.blit(paint(item_name, name_blit, background_blit))
			screen.blit(paint(item_count, count_blit, background_blit))
		end
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
		config = configuration,
	}, METATABLE)

	return new_storagedisplay
end

return StorageDisplay
