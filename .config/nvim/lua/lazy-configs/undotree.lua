local export = { "mbbill/undotree" }

export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("U", "UndotreeToggle", {})
end

export.cmd = { "UndotreeToggle" }

export.config = function()
	vim.api.nvim_set_var("undotree_SetFocusWhenToggle", 1)
end

return export
