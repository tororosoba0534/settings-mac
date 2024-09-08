local export = { "karb94/neoscroll.nvim" }

export.lazy = true
export.keys = { "<C-u>", "<C-d>", "zt", "zz", "zb" }
export.config = function()
	require("neoscroll").setup({
		mappings = { "<C-u>", "<C-d>", "zt", "zz", "zb" },
		hide_cursor = false,
	})
end

return export
