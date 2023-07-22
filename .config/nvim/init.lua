-- GENERAL CAVIEATS
-- * <F3> is mapped <C-i> to by karabiner so that <C-i> and <Tab> be mapped to the other functionality.

-- Disable netrw at the very start of your init.lua
-- Strongly recommended when you use nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = "/usr/local/bin/python3"

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
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	"nvim-telescope/telescope-live-grep-args.nvim",
	{ "folke/trouble.nvim", dependencies = "nvim-tree/nvim-web-devicons" },
	{ "akinsho/toggleterm.nvim", version = "*", config = true },
	"neovim/nvim-lspconfig",
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
	},
	"williamboman/mason-lspconfig.nvim",
	-- "L3MON4D3/LuaSnip",
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"SirVer/ultisnips",
	"quangnguyen30192/cmp-nvim-ultisnips",
	-- "saadparwaiz1/cmp_luasnip",
	{ "jose-elias-alvarez/null-ls.nvim", dependencies = "nvim-lua/plenary.nvim" },
	"MunifTanjim/prettier.nvim",
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	"numToStr/Comment.nvim",
	-- You need "im-select" executable on Mac
	-- https://github.com/daipeihust/im-select
	-- ```
	-- # If you use Intel chip on your Mac, change 'apple' to 'intel' in the following code:
	-- sudo curl -L -o /usr/local/bin/im-select https://github.com/daipeihust/im-select/raw/master/im-select-mac/out/apple/im-select
	-- sudo chmod 755 /usr/local/bin/im-select
	-- ```
	-- "keaising/im-select.nvim",
	{
		"chrisgrieser/nvim-recorder",
		opts = {},
	},
	-- "unblevable/quick-scope",
	-- "haya14busa/vim-edgemotion",
	-- "phaazon/hop.nvim",
	"karb94/neoscroll.nvim",
	"zbirenbaum/copilot.lua",
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	-- BLOCKEND
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
	-- typescript-language-server settings
	-- CAUTION!
	-- If you use yarn Plug'n'Play installs (.pnp.cjs), you should:
	-- 1. Install "project-local" typescript-language-server
	--   `$ yarn add -D typescript-language-server`
	-- 2. Execute below command to generate a new directory called `.yarn/sdks`
	--   `$ yarn dlx @yarnpkg/sdks base`
	["tsserver"] = function()
		lspconfig.tsserver.setup({
			filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
			capabilities = capabilities,
		})
	end,
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			-- require("luasnip").lsp_expand(args.body)
			vim.fn["UltiSnips#Anon"](args.body)
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
		{ name = "copilot", group_index = 2 },
		{ name = "nvim_lsp" },
		{ name = "ultisnips" },
	}),
})

vim.keymap.set("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>")
-- vim.keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.formatting()<CR>")
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
		null_ls.builtins.formatting.goimports,
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

require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript" },
	auto_install = false,
	highlight = {
		enable = true,
		disable = function(_, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
	},
})

vim.keymap.set({ "n" }, "<F3>", "<C-i>")
vim.keymap.set({ "i", "l", "v", "o", "t" }, "<F3>", "<NOP>")

local indent_stay_cursor = require("indent-stay-cursor")
vim.keymap.set({ "n", "i" }, "<TAB>", indent_stay_cursor.shift_right_line, { noremap = true })
vim.keymap.set({ "n", "i" }, "<S-TAB>", indent_stay_cursor.shift_left_line, { noremap = true })

-- <C-_> means ctrl + slash(/)
require("Comment").setup({
	-- sticky = false,
})
-- vim.keymap.set("n", "<C-_>", "<Plug>(comment_toggle_linewise_current)")
vim.keymap.set("x", "<C-_>", "<Plug>(comment_toggle_linewise_visual)")
vim.keymap.set({ "n", "i" }, "<C-_>", indent_stay_cursor.toggle_comment)

require("nvim-web-devicons").setup({})

-- Usage:
-- <TAB> -> preview
-- q     -> close window
require("nvim-tree").setup()
-- vim.keymap.set("n", "<C-w>F", "<cmd>NvimTreeToggle<CR>")
-- vim.keymap.set("n", "<C-w>S", "<cmd>NvimTreeToggle ~/settings-mac<CR>")
-- vim.keymap.set("n", "<C-w>N", "<cmd>NvimTreeToggle ~/Notes<CR>")
vim.api.nvim_create_user_command("F", "NvimTreeToggle", {})

local telescope = require("telescope")
require("telescope").load_extension("live_grep_args")
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
			-- search_dirs = { "./", "~/settings-mac/" },
		},
	},
	extensions = {
		live_grep_args = {},
	},
})
vim.keymap.set("n", "<C-w>f", "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<C-w>b", "<cmd>Telescope buffers<CR>")
vim.keymap.set("n", "<C-w>F", '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<CR>')
-- vim.api.nvim_create_user_command("F", "lua require(\"telescope\").extensions.live_grep_args.live_grep_args()", {})

local notetaking = require("notetaking")
vim.keymap.set("n", "gf", function()
	notetaking.main()
end)

vim.api.nvim_set_var("undotree_SetFocusWhenToggle", 1)
vim.keymap.set("n", "<C-w>u", "<cmd>UndotreeToggle<CR>")

vim.opt.termguicolors = true
require("bufferline").setup({})

require("trouble").setup({})
vim.keymap.set("n", "<C-w>e", "<cmd>TroubleToggle<CR>")

-- You need "im-select" executable on Mac
-- https://github.com/daipeihust/im-select
-- ```
-- # If you use Intel chip on your Mac, change 'apple' to 'intel' in the following code:
-- sudo curl -L -o /usr/local/bin/im-select https://github.com/daipeihust/im-select/raw/master/im-select-mac/out/apple/im-select
-- sudo chmod 755 /usr/local/bin/im-select
-- ```
require("im-select").setup()

vim.cmd("call UltiSnips#RefreshSnippets()")

-- local hop = require("hop")
-- hop.setup({
-- 	multi_windows = true,
-- })
-- vim.keymap.set("", "f", "<cmd>HopWordCurrentLine<CR>")
-- vim.keymap.set("", "F", "<cmd>HopLineStart<CR>")
-- vim.cmd([[hi HopUnmatched ctermfg=15 guifg=White]])

require("neoscroll").setup({
	mappings = { "<C-u>", "<C-d>", "zt", "zz", "zb" },
	hide_cursor = false,
})

require("copilot").setup({
	suggestion = { enabled = false },
	panel = { enabled = false },
})
-- BLOCKEND

-- -- The following line envokes error.
-- vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
vim.keymap.set("n", "<C-j>", "<Plug>(edgemotion-j)")
vim.keymap.set("n", "<C-k>", "<Plug>(edgemotion-k)")

vim.o.mouse = "a"
vim.o.tabstop = 4
vim.o.number = true
-- -- scrolloff disabled because of hop.nvim user experience
-- vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = ">>>"
vim.o.statusline = "%F%=%l/%L lines (%p%%)"
vim.o.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true

-- BLOCKEND

vim.api.nvim_create_user_command("Stg", "edit $MYVIMRC", {})

-- CHEAT SEAT
-- :so % <- source current file (useful when you develop plugin in lua or vimscript)
-- :noh <- turn off syntax hilight

vim.keymap.set({ "", "!" }, "<C-g>", "<ESC>")
vim.keymap.set({ "", "!" }, "<C-f>", "<RIGHT>")
vim.keymap.set({ "", "!" }, "<C-b>", "<LEFT>")
vim.keymap.set({ "", "!" }, "<C-n>", "<Down>")
vim.keymap.set({ "", "!" }, "<C-p>", "<Up>")
vim.keymap.set("n", "J", "j<C-e>")
vim.keymap.set("n", "K", "k<C-y>")
vim.keymap.set({ "", "!" }, "<C-a>", "<HOME>")
vim.keymap.set({ "", "!" }, "<C-e>", "<END>")
vim.keymap.set("i", "<C-k>", "<ESC>lDa")
--
vim.keymap.set("n", "<C-w>/", ":below vsplit<CR>")
vim.keymap.set("n", "<C-w>-", ":below split<CR>")
vim.keymap.set("n", "<C-w>c", ":close<CR>")
vim.keymap.set("n", "<C-w>C", ":only<CR>")
vim.keymap.set("n", "<C-w>d", ":bn | bd#<CR>")
vim.keymap.set("n", "<C-w>D", ":%bd | e# | bd#<CR>")
vim.keymap.set("n", "<C-w>j", ":wincmd w<CR>")
vim.keymap.set("n", "<C-w>k", ":wincmd W<CR>")
vim.keymap.set("n", "<C-w>h", ":bprev<CR>")
vim.keymap.set("n", "<C-w>l", ":bnext<CR>")
-- vim.keymap.set("n", "<C-w>w", ":vert res +25<CR>")
-- vim.keymap.set("n", "<C-w>W", ":vert res -25<CR>")
-- vim.keymap.set("n", "<C-w>t", ":res +15<CR>")
-- vim.keymap.set("n", "<C-w>T", ":res -15<CR>")
-- vim.keymap.set("n", "<C-w>=", ":horizontal wincmd =<CR>")
