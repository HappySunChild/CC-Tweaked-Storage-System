local Cache = {}
local CacheClass = {}

function Cache.new(fallback)
	local newCache = setmetatable({
		values = {},
		fallback = fallback,
	}, { __index = CacheClass })

	return newCache
end

function CacheClass:get(index, fallback)
	fallback = fallback or self.fallback

	local value = self.values[index]

	if value == nil and fallback then
		value = fallback(index)

		self:set(index, value)
	end

	return value
end

function CacheClass:set(index, value)
	self.values[index] = value
end

function CacheClass:clear()
	table.clear(self.values)
end

return Cache
