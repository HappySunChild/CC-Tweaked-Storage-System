local CONFIG_PATH = '.storage_system.config'

local Configuration = {}
Configuration.config = {
	TruncateText = true,
	RefreshRate = 5,
	SortOrder = 'Desc',
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
		local loadedConfig = settings.get('StorageSystemConfig', self.config)
		
		for index, value in pairs(loadedConfig) do
			self.config[index] = value
		end
	end
end

function Configuration:Save()
	settings.set('StorageSystemConfig', self.config)
	settings.save(CONFIG_PATH)
end

return Configuration