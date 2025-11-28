local function yield_for_user()
	os.pullEvent("key")
	os.pullEvent("key_up")
end

return yield_for_user
