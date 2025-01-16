local export = { "stevearc/conform.nvim" }

export.lazy = true

export.event = { "TextChanged" }

export.config = function()
	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			nix = { "nixfmt" },
			go = { "goimports", "gofmt", stop_after_first = false },
			rust = { "rustfmt" },
			kotlin = { "ktlint" },
			python = { "isort", "black" },
			html = { "prettierd", "prettier", stop_after_first = true },
			css = { "prettierd", "prettier", stop_after_first = true },
			json = { "prettierd", "prettier", stop_after_first = true },
			yaml = { "prettierd", "prettier", stop_after_first = true },
			markdown = { "prettierd", "prettier", stop_after_first = true },
			graphql = { "prettierd", "prettier", stop_after_first = true },
			javascript = { "prettierd", "prettier", stop_after_first = true },
			typescript = { "prettierd", "prettier", stop_after_first = true },
			javascriptreact = { "prettierd", "prettier", stop_after_first = true },
			typescriptreact = { "prettierd", "prettier", stop_after_first = true },
			cpp = { "clang-format" },
		},
		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true,
			async = false,
		},
	})
end

return export
