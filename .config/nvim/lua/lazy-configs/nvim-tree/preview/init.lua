local modemgr = require('lazy-configs.nvim-tree.preview.mode-manager')

local export = {}

export.is_watching = function()
	return modemgr:is('watch')
end

export.watch = function()
	return modemgr:to_watch_mode()
end

export.enter = function()
	return modemgr:to_enter_mode()
end

export.exit = function()
	return modemgr:to_tree_mode()
end

return export
