local function download(path)
	local link = 'https://raw.githubusercontent.com/HappySunChild/CC-Tweaked-Storage-System/refs/heads/main/storagesystem/' .. path
	
	return shell.execute('wget', link, path)
end

local files = {
	'main.lua',
	'theme.lua',
	'config.lua',
	'setup.lua',
	'system.lua',
	
	'themes/default.lua',
	'themes/light.lua',
	'themes/dark.lua',
	'themes/kimbie.lua',
	'themes/matrix.lua',
	
	'utility/cache.lua',
	'utility/numbers.lua',
	'utility/ui.lua',
	'utility/table.lua'
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