-- Disable netrw at the very start of your init.lua
-- Strongly recommended when you use nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- lazy.nvim -- plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	"mbbill/undotree",
	"nvim-tree/nvim-tree.lua",
	{
		"akinsho/bufferline.nvim",
		version = "v3.*",
		dependencies = "nvim-tree/nvim-web-devicons",
	},
	-- fzf-lua
	-- You need "fzf" & "rg"
	{ "ibhagwan/fzf-lua", dependencies = "nvim-tree/nvim-web-devicons" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	{ "folke/trouble.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
	{ "akinsho/toggleterm.nvim", version = "*", config = true },
	"neovim/nvim-lspconfig",
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	"williamboman/mason-lspconfig.nvim",
	"L3MON4D3/LuaSnip",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"saadparwaiz1/cmp_luasnip",
	{ "jose-elias-alvarez/null-ls.nvim", dependencies = "nvim-lua/plenary.nvim" },
	"MunifTanjim/prettier.nvim",
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
})

-- LSP settings
-- Setup order is important (see h: mason-lspconfig-quickstart):
-- 1. mason.nvim
-- 2. mason-lspconfig.nvim
-- 3. language server setups through nvim-lspconfig
--
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup({
	ensure_installed = { "lua_ls", "tsserver", "jsonls" },
	automatic_installation = true,
})
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
mason_lspconfig.setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({
			capabilities = capabilities,
		})
	end,
	["lua_ls"] = function()
		lspconfig.lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
				},
			},
			capabilities = capabilities,
		})
	end,
	["tsserver"] = function()
		lspconfig.tsserver.setup({
			filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
			capabilities = capabilities,
		})
	end,
})

-- lspconfig.jsonls.setup({
-- 	capabilities = capabilities,
-- })

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-l>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		}),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
	}),
})

vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
vim.keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
vim.keymap.set("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")
vim.keymap.set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>")
vim.keymap.set("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
vim.keymap.set("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
vim.keymap.set("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

-- vim.cmd([[
-- set updatetime=500
-- highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
-- highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
-- highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
-- augroup lsp_document_highlight
--   autocmd!
--   autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
--   autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
-- augroup END
-- ]])

vim.opt.completeopt = { "menu", "menuone", "noselect" }

local augroup_null_ls_format_on_save = vim.api.nvim_create_augroup("LspFormatting", {})
local null_ls = require("null-ls")
null_ls.setup({
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.diagnostics.eslint.with({
			prefer_local = "node_modules/.bin",
		}),
		null_ls.builtins.formatting.prettier.with({
			prefer_local = "node_modules/.bin",
		}),
		-- null_ls.builtins.formatting.prettierd,
		-- null_ls.builtins.diagnostics.eslint_d.with({
		-- 	diagnostics_format = '[eslint] #{m}\n(#{c})'
		-- })
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup_null_ls_format_on_save, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup_null_ls_format_on_save,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
-- local prettier = require("prettier")
-- prettier.setup({
-- 	bin = "prettierd",
-- 	filetypes = {
-- 		"css",
-- 		"javascript",
-- 		"javascriptreact",
-- 		"typescript",
-- 		"typescriptreact",
-- 		"json",
-- 		"scss",
-- 		"less",
-- 	},
-- })

require("nvim-web-devicons").setup({})

require("nvim-tree").setup()
vim.api.nvim_set_keymap("n", "<C-w>F", ":NvimTreeToggle<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>S", ":NvimTreeToggle ~/settings-mac<CR>", { noremap = true })

-- require("fzf-lua").setup({
-- 	lsp = {
-- 		-- needed for null-ls.nvim
-- 		async_or_timeout = 3000,
-- 	},
-- })
-- vim.api.nvim_set_keymap("n", "<C-w>f", ":FzfLua files<CR>", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<C-w>s", ":FzfLua files cwd=~/settings-mac<CR>", { noremap = true })
-- vim.api.nvim_create_augroup("fzf", { clear = true })
-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	pattern = { "fzf" },
-- 	command = "tnoremap <buffer> <C-w>f <ESC>",
-- })
-- vim.api.nvim_create_autocmd({ "FileType" }, {
-- 	pattern = { "fzf" },
-- 	command = "tnoremap <buffer> <C-w>s <ESC>",
-- })
local telescope = require("telescope")
local telescope_actions = require("telescope.actions")
telescope.setup({
	defaults = {
		file_ignore_patterns = { "node_modules", ".git" },
		mappings = {
			i = {
				["<C-w>f"] = telescope_actions.close,
				["<esc>"] = telescope_actions.close,
				["<C-g>"] = telescope_actions.close,
				["q"] = telescope_actions.close,
			},
			n = {
				["<C-w>f"] = telescope_actions.close,
				["<esc>"] = telescope_actions.close,
				["<C-g>"] = telescope_actions.close,
				["q"] = telescope_actions.close,
			},
		},
	},
	pickers = {
		find_files = {
			hidden = true,
			search_dirs = { "./", "~/settings-mac/" },
		},
	},
	extensions = {
		file_browser = {
			hidden = true,
		},
	},
})
telescope.load_extension("file_browser")
vim.api.nvim_set_keymap("n", "<C-w>f", ":Telescope find_files<CR>", { noremap = true })

vim.api.nvim_set_var("undotree_SetFocusWhenToggle", 1)
vim.api.nvim_set_keymap("n", "<C-w>u", ":UndotreeToggle<CR>", { noremap = true })

vim.opt.termguicolors = true
require("bufferline").setup({})

require("trouble").setup({})
vim.api.nvim_set_keymap("n", "<C-w>e", ":TroubleToggle<CR>", { noremap = true })

vim.o.number = true
vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = ">>>"
vim.o.statusline = "%F%=%l/%L lines (%p%%)"
vim.o.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"

vim.api.nvim_create_user_command("Stg", "edit $MYVIMRC", {})

vim.api.nvim_set_keymap("", "<C-g>", "<ESC>", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-g>", "<ESC>", { noremap = true })
vim.api.nvim_set_keymap("", "<C-f>", "<Right>", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-f>", "<Right>", { noremap = true })
vim.api.nvim_set_keymap("", "<C-b>", "<Left>", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-b>", "<Left>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-n>", "gj", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-n>", "<Down>", { noremap = true })
vim.api.nvim_set_keymap("", "<C-p>", "gk", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-p>", "<Up>", { noremap = true })
vim.api.nvim_set_keymap("n", "J", "j<C-e>", { noremap = true })
vim.api.nvim_set_keymap("n", "K", "k<C-y>", { noremap = true })
vim.api.nvim_set_keymap("", "<C-a>", "<HOME>", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-a>", "<HOME>", { noremap = true })
vim.api.nvim_set_keymap("", "<C-e>", "<END>", { noremap = true })
vim.api.nvim_set_keymap("!", "<C-e>", "<END>", { noremap = true })
vim.api.nvim_set_keymap("i", "<C-k>", "<ESC>lDa", { noremap = true })

vim.api.nvim_set_keymap("n", "<C-w>/", ":below vsplit<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>-", ":below split<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>c", ":close<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>C", ":only<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>d", ":bn | bd#<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>D", ":%bd | e# | bd#<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>j", ":wincmd w<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>k", ":wincmd W<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>h", ":bprev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>l", ":bnext<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>w", ":vert res +25<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>W", ":vert res -25<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>t", ":res +15<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>T", ":res -15<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-w>=", ":horizontal wincmd =<CR>", { noremap = true })
