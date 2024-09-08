local export = { 'stevearc/conform.nvim' }

export.lazy = true

export.event = { "TextChanged" }

export.config = function()
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "goimports", "gofmt" },
			rust = { "rustfmt" },
			kotlin = { "ktlint" },
			python = { "isort", "black" },
			html = { { "prettierd", "prettier" } },
			css = { { "prettierd", "prettier" } },
			json = { { "prettierd", "prettier" } },
			yaml = { { "prettierd", "prettier" } },
			markdown = { { "prettierd", "prettier" } },
			graphql = { { "prettierd", "prettier" } },
			javascript = { { "prettierd", "prettier" } },
			typescript = { { "prettierd", "prettier" } },
			javascriptreact = { { "prettierd", "prettier" } },
			typescriptreact = { { "prettierd", "prettier" } },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true,
			async = false,
		},
	})
end

return export
