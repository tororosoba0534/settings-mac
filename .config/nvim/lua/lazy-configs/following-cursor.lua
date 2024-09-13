local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/following-cursor.lua"

export.lazy = true

export.event = 'BufEnter'

export.config = function()
	vim.keymap.set({ 'i', 'x' }, '<Tab>', require('following-cursor').increase_indent,
		{ noremap = true, silent = false })
	vim.keymap.set({ 'i', 'x' }, '<S-Tab>', require('following-cursor').decrease_indent,
		{ noremap = true, silent = false })

	-- vim.keymap.set({ 'x' }, '<Tab>', require('following-cursor').get_selection_lines,
	-- 		{ noremap = true, silent = false })
end

return export
