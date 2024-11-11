local watcher = require('lazy-configs.nvim-tree.preview.watcher')
local enterer = require('lazy-configs.nvim-tree.preview.enterer')

local export = {}

---@type Keymap[]
local preview_buf_keymaps = {
	{
		key = 'o',
		callback = function()
			enterer:exit(true)
			watcher:watch()
		end,
	},
	{
		key = 'O',
		callback = function()
			enterer:exit(true)
			watcher:unwatch()
		end,
	},
}

export.is_watching = function()
	return watcher:is_watching()
end

export.watch = function()
	enterer:exit(true)
	watcher:watch()
end

export.unwatch = function()
	watcher:unwatch()
end

export.enter = function()
	watcher:unwatch()
	enterer:enter(preview_buf_keymaps)
end

export.exit = function()
	enterer:exit(true)
end

return export
