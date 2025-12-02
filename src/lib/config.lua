local SETTING_IO_INVENTORY = "storage.io_inventory"
local SETTING_SYSTEM_INVENTORIES = "storage.system_inventories"
local SETTING_PROCESSORS = "storage.processors"
local SETTING_MONITOR_COLUMNS = "storage.monitor_columns"

settings.define(SETTING_IO_INVENTORY, {
	type = "string",
	description = "The inventory the system uses for IO operations.",
})
settings.define(SETTING_SYSTEM_INVENTORIES, {
	type = "table",
	description = "The inventories the system has registered.",
})
settings.define(SETTING_PROCESSORS, {
	type = "table",
	description = "The processors the system has registered.",
})
settings.define(SETTING_MONITOR_COLUMNS, {
	default = 2,
	type = "number",
	description = "The number of columns to render on the monitor.",
})

return {
	settings = {
		IO_INVENTORY = SETTING_IO_INVENTORY,
		SYSTEM_INVENTORIES = SETTING_SYSTEM_INVENTORIES,
		PROCESSORS = SETTING_PROCESSORS,
		MONITORS_COLUMNS = SETTING_MONITOR_COLUMNS,
	},

	get = function(name)
		return settings.get(name)
	end,
	set = function(name, value)
		settings.set(name, value)
	end,
	load = function()
		settings.load()
	end,
	save = function()
		settings.save()
	end,
}
