local export = { 'williamboman/mason.nvim' }

export.dependencies = {
	'williamboman/mason-lspconfig.nvim',
	"WhoIsSethDaniel/mason-tool-installer.nvim",
}

export.cmd = "Mason"

export.config = function()
	require("mason").setup()
	require("mason-lspconfig").setup({
		ensure_installed = {
			"lua_ls",
			"rust_analyzer",
			"gopls",
			"jsonls",
			"ts_ls",
			"html",
			"cssls",
			"pyright",
			"graphql",
			"kotlin_language_server",
			"texlab",
			"hls",
		},
		automatic_installation = true,
	})
	require("mason-tool-installer").setup({
		ensure_installed = {
			"stylua",
			"prettier",
			"prettierd",
			"ktlint",
			"goimports",
			"isort",
			"black",
			-- -- rustfmt must be installed via rustup
			-- "rustfmt",
		}
	})
end

return export
