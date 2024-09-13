local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/indenter.lua"

export.lazy = true

export.event = 'BufEnter'

export.config = function()
	vim.keymap.set({ 'i', 'x' }, '<Tab>', require('indenter').increase,
		{ noremap = true, silent = false })
	vim.keymap.set({ 'i', 'x' }, '<S-Tab>', require('indenter').decrease,
		{ noremap = true, silent = false })
end

return export
