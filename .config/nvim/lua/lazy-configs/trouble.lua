local export = { "folke/trouble.nvim" }

export.dependencies = "nvim-tree/nvim-web-devicons"
export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("E", "Trouble diagnostics toggle focus=true", {})
end

export.cmd = { 'Trouble' }

export.config = function()
	require("trouble").setup({})
end

return export
