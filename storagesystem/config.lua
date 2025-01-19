local CONFIG_PATH = '.storage_system.config'

local Configuration = {}
Configuration.config = {
	UserTheme = 'default',
	SortOrder = 'Desc',
	BufferInventory = '',
	
	TruncateText = true,
	TabInventorySelect = false,
	
	RefreshRate = 5
}

---@param name string
---@return any
function Configuration:Get(name)
	return self.config[name]
end

function Configuration:Set(name, value)
	self.config[name] = value
end


function Configuration:Load()
	local exists = settings.load(CONFIG_PATH)
	
	if exists then
		local loadedConfig = settings.get('storagesystem.config', self.config)
		
		for index, value in pairs(loadedConfig) do
			self.config[index] = value
		end
	end
	
	return exists
end

function Configuration:Save()
	settings.set('storagesystem.config', self.config)
	settings.save(CONFIG_PATH)
end

return Configuration