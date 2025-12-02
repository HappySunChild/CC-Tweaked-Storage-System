return {
	list = function()
		local items = {}

		for slot = 1, 16 do
			items[slot] = turtle.getItemDetail(slot)
		end

		return items
	end,
}
