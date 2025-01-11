local function download(path)
	local link = 'https://raw.githubusercontent.com/HappySunChild/CC-Tweaked-Storage-System/main/storagesystem/' .. path
	
	return shell.execute('wget', link, path)
end

local files = {
	'main.lua',
	'theme.lua',
	
	'themes/default.lua',
	'themes/matrix.lua',
	
	'utility/cache.lua',
	'utility/numbers.lua',
	'utility/progressbar.lua',
	'utility/ui.lua'
}

local failed = {}

for _, path in ipairs(files) do
	if fs.exists(path) then
		fs.delete(path)
	end
	
	local success = download(path)
	
	if not success then
		table.insert(failed, path)
	end
end

if #failed > 0 then
	term.clear()
	term.setCursorPos(1, 1)
	
	printError('Failed to downloading the following files:')
	
	for _, path in ipairs(failed) do
		print(path)
	end
end