local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/nvim-window.lua"

export.lazy = true

export.keys = { '<Leader><Leader>', '<Leader>c' }

export.config = function()
	require('nvim-window').setup({
	})
	vim.keymap.set({ 'n' }, '<Leader><Leader>', require('nvim-window').pick,
		{ noremap = true, silent = true })
	vim.keymap.set({ 'n' }, '<Leader>c', require('nvim-window').close,
		{ noremap = true, silent = true })
end

return export
