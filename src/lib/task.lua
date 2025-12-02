local queue = {} ---@type QueuedTask[]
local active = {} ---@type Task[]

---@class QueuedTask
---@field thread thread
---@field args any[]

---@class Task
---@field thread thread
---@field filter string?

---@param thread thread
---@param ... any
---@return ...
local function checked_resume(thread, ...)
	local ok, result = coroutine.resume(thread, ...)

	if ok then
		return result
	end

	printError(result)
end

---@param thread thread
---@param ... any
local function start_task(thread, ...)
	local filter = checked_resume(thread, ...)

	if coroutine.status(thread) ~= "dead" then
		table.insert(active, { thread = thread, filter = filter })
	end
end

return {
	---Immediately runs the passed function.
	---@param func function
	---@param ... any
	spawn = function(func, ...)
		local thread = coroutine.create(func)

		-- directly adds to active!
		start_task(thread, ...)
	end,
	---Runs the passed function in the next
	---@param func function
	defer = function(func, ...)
		local thread = coroutine.create(func)

		table.insert(queue, { thread = thread, args = table.pack(...) })
	end,

	---Starts the scheduler.
	start_scheduler = function()
		while true do
			-- process queue
			while #queue > 0 do
				local queued_task = table.remove(queue, 1) ---@type QueuedTask

				start_task(queued_task.thread, table.unpack(queued_task.args))
			end

			-- process active threads
			local event = table.pack(os.pullEvent())
			local event_name = event[1]

			for index = #active, 1, -1 do
				local task = active[index]

				if task.filter == nil or task.filter == event_name then
					local thread = task.thread
					local new_filter = checked_resume(thread, table.unpack(event))

					if coroutine.status(thread) == "dead" then
						table.remove(active, index)
					else
						task.filter = new_filter
					end
				end
			end
		end
	end,
}
