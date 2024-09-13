local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/following-cursor.lua"

export.lazy = true

export.event = 'BufEnter'

export.config = function()
	vim.keymap.set({ 'i' }, '<Tab>', require('following-cursor').increase_indent,
		{ noremap = true, silent = false })
	vim.keymap.set({ 'i' }, '<S-Tab>', require('following-cursor').decrease_indent,
		{ noremap = true, silent = false })
end

return export
