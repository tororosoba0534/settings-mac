local modemgr = require('custom.nvim-tree.preview.mode-manager')
local config = require('custom.nvim-tree.preview.config')

local export = {}

---@param opts Config
export.setup = function(opts)
	config:set(opts)
end

export.is_watch_mode = function()
	return modemgr:is('watch')
end

export.is_enter_mode = function()
	return modemgr:is('enter')
end

export.is_exit_mode = function()
	return modemgr:is('exit')
end

export.watch = function()
	return modemgr:to_watch_mode()
end

export.enter = function()
	return modemgr:to_enter_mode()
end

export.exit = function()
	return modemgr:to_exit_mode()
end

return export
