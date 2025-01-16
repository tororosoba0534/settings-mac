local export = { "neovim/nvim-lspconfig" }

export.event = { "BufReadPre", "BufNewFile" }

export.dependencies = {
	"hrsh7th/cmp-nvim-lsp",
	{ "antosha417/nvim-lsp-file-operations" },
}

export.init = function()
	local opts = { noremap = true, silent = true }

	opts.desc = "Show documentation for what is under cursor"
	vim.keymap.set("n", "gh", function()
		vim.lsp.buf.hover()
		vim.lsp.buf.clear_references()
		vim.lsp.buf.document_highlight()
	end, opts)

	opts.desc = "Show buffer diagnostics"
	vim.keymap.set("n", "gH", "<CMD>Telescope diagnostics bufnr=0<CR>", opts)

	opts.desc = "Show LSP definitions"
	vim.keymap.set("n", "gd", "<CMD>Telescope lsp_definitions<CR>", opts)

	opts.desc = "Go to declaration"
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

	opts.desc = "Show LSP type definitions"
	vim.keymap.set("n", "gt", "<CMD>Telescope lsp_type_definitions<CR>", opts)

	opts.desc = "Show LSP implementation"
	vim.keymap.set("n", "gi", "<CMD>Telescope lsp_implementations<CR>", opts)

	opts.desc = "Show LSP references"
	vim.keymap.set("n", "gr", "<CMD>Telescope lsp_references<CR>", opts)

	opts.desc = "Smart rename"
	vim.keymap.set({ "n" }, "gR", vim.lsp.buf.rename, opts)

	opts.desc = "See available LSP actions"
	vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, opts)
	-- opts.desc = "Show line diagnostics"
	-- vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
	-- opts.desc = "Go to previous diagnostic"
	-- vim.keymap.set("n", "gn", vim.diagnostic.goto_prev, opts)
	-- opts.desc = "Go to next diagnostic"
	-- vim.keymap.set("n", "gp", vim.diagnostic.goto_next, opts)
	-- opts.desc = "Restart LSP"
	-- vim.keymap.set("n", "<leader>rs", "<CMD>LspRestart<CR>", opts)
end

export.config = function()
	local capabilities = require("cmp_nvim_lsp").default_capabilities()
	local lspconfig = require("lspconfig")
	lspconfig["html"].setup({
		capabilities = capabilities,
	})
	lspconfig["jsonls"].setup({
		capabilities = capabilities,
	})
	lspconfig["cssls"].setup({
		capabilities = capabilities,
	})
	lspconfig["graphql"].setup({
		capabilities = capabilities,
	})
	lspconfig["pyright"].setup({
		capabilities = capabilities,
	})
	lspconfig["rust_analyzer"].setup({
		capabilities = capabilities,
	})
	lspconfig["gopls"].setup({
		capabilities = capabilities,
	})
	lspconfig["kotlin_language_server"].setup({
		capabilities = capabilities,
	})
	lspconfig["texlab"].setup({
		capabilities = capabilities,
	})
	lspconfig["ts_ls"].setup({
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"typescriptreact",
			"typescript.tsx",
			"javascript",
			"javascriptreact",
			"javascript.tsx",
		},
	})
	lspconfig["lua_ls"].setup({
		capabilities = capabilities,
		settings = { -- custom settings for lua
			Lua = {
				runtime = {
					version = "Lua 5.1",
				},
				-- make the language server recognize "vim" global
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					-- make language server aware of runtime files
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					},
				},
			},
		},
	})
	lspconfig["nil_ls"].setup({
		capabilities = capabilities,
	})
	lspconfig["hls"].setup({
		capabilities = capabilities,
	})
	lspconfig["clangd"].setup({
		capabilities = capabilities,
	})
end

return export
