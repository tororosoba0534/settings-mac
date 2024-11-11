local watcher = require('lazy-configs.nvim-tree.preview.watcher')
local enterer = require('lazy-configs.nvim-tree.preview.enterer')

local export = {}

export.is_watching = function()
	return watcher:is_watching()
end

export.watch = function()
	watcher:watch()
end

export.unwatch = function()
	watcher:unwatch()
end

export.enter = function()
	enterer:enter()
end

return export
