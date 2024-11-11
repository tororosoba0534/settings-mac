local modemgr = require('custom.nvim-tree.preview.mode-manager')
local config = require('custom.nvim-tree.preview.config')

local export = {}

---@param opts Config
export.setup = function(opts)
	config:set(opts)
end

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
