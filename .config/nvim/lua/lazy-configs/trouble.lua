local export = { "folke/trouble.nvim" }

export.dependencies = "nvim-tree/nvim-web-devicons"
export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("E", "TroubleToggle", {})
end

export.cmd = { "TroubleToggle" }

export.config = function()
	require("trouble").setup({})
end

return export
