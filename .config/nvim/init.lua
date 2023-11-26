--------------------------------------------------
--------------------------------------------------
-- BASIC SETTINGS
--------------------------------------------------
--------------------------------------------------

-- Disable netrw at the very start of your init.lua
-- Strongly recommended when you use nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- -- DO NOT set below option.
-- -- since the location of python3 executable differs between Intel Mac and M1 Mac.
-- -- If you are in trouble of python3 provider, please make sure your pip version is latest.
-- vim.g.python3_host_prog = "/usr/local/bin/python3"

--------------------------------------------------
--------------------------------------------------
-- LOAD PLUGINS
--------------------------------------------------
--------------------------------------------------
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
	-- LSP settings
	-- Setup order is important (see h: mason-lspconfig-quickstart):
	-- 1. mason.nvim
	-- 2. mason-lspconfig.nvim
	-- 3. language server setups through nvim-lspconfig
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- :MasonUpdate updates registry contents
		config = function()
			require("mason").setup()
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local mason_lspconfig = require("mason-lspconfig")
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"tsserver",
					"jsonls",
					"rust_analyzer",
					"gopls",
				},
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
		end
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"jay-babu/mason-null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"jose-elias-alvarez/null-ls.nvim",
		},
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					"goimports",
				},
				automatic_installation = false,
				handlers = {},
			})
		end
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
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
		end
	},
	{
		"hrsh7th/nvim-cmp",
		config = function()
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
					["<Tab>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				sources = cmp.config.sources({
					{ name = "copilot",  group_index = 2 },
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
		end
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({})
		end
	},

	{
		"mbbill/undotree",
		lazy = true,
		init = function()
			vim.api.nvim_create_user_command("U", "UndotreeToggle", {})
		end,
		cmd = { "UndotreeToggle" },
		config = function()
			vim.api.nvim_set_var("undotree_SetFocusWhenToggle", 1)
		end
	},
	{
		"nvim-tree/nvim-tree.lua",
		lazy = true,
		init = function()
			-- vim.keymap.set("n", "<C-w>F", "<cmd>NvimTreeToggle<CR>")
			-- vim.keymap.set("n", "<C-w>S", "<cmd>NvimTreeToggle ~/settings-mac<CR>")
			-- vim.keymap.set("n", "<C-w>N", "<cmd>NvimTreeToggle ~/Notes<CR>")
			vim.api.nvim_create_user_command("F", "NvimTreeToggle", {})
			vim.api.nvim_create_user_command(
				'NvimTreeOpenTreeWithoutFocus',
				function()
					require("nvim-tree.api").tree.toggle({ focus = false })
				end,
				{ nargs = 0 }
			)
		end,
		cmd = { "NvimTreeToggle", "NvimTreeOpenTreeWithoutFocus" },
		config = function()
			local nvim_tree = require("nvim-tree")
			local nvim_tree_api = require("nvim-tree.api")
			nvim_tree.setup({
				on_attach = function(bufnr)
					local function opts(desc)
						return {
							desc = 'nvim-tree: ' .. desc,
							buffer = bufnr,
							noremap = true,
							silent = true,
							nowait = true
						}
					end
					vim.keymap.set('n', '<CR>', nvim_tree_api.node.open.edit, opts('Open'))
					vim.keymap.set('n', '<2-LeftMouse>', nvim_tree_api.node.open.edit, opts('Open'))
					vim.keymap.set('n', 'o', function(node)
						nvim_tree_api.node.open.edit(node)
						nvim_tree_api.tree.focus()
					end, opts('Open and focus tree'))
					vim.keymap.set('n', 'x', nvim_tree_api.fs.cut, opts('Cut'))
					vim.keymap.set('n', 'c', nvim_tree_api.fs.copy.node, opts('Copy'))
					vim.keymap.set('n', 'y', nvim_tree_api.fs.copy.node, opts('Copy'))
					vim.keymap.set('n', 'p', nvim_tree_api.fs.paste, opts('Paste'))
					vim.keymap.set('n', 'v', nvim_tree_api.fs.paste, opts('Paste'))
					vim.keymap.set('n', 'd', nvim_tree_api.fs.remove, opts('Delete'))
					vim.keymap.set('n', 'r', nvim_tree_api.fs.rename, opts('Rename'))
					vim.keymap.set('n', 'a', nvim_tree_api.fs.create, opts('Create'))
					vim.keymap.set('n', '/', nvim_tree_api.node.open.vertical, opts('Open vertically'))
					vim.keymap.set('n', '?', function(node)
						nvim_tree_api.node.open.vertical(node)
						nvim_tree_api.tree.focus()
					end, opts('Open vertically and keep focus'))
					vim.keymap.set('n', '-', nvim_tree_api.node.open.horizontal, opts('Open horizontally'))
					vim.keymap.set('n', '_', function(node)
						nvim_tree_api.node.open.horizontal(node)
						nvim_tree_api.tree.focus()
					end, opts('Open horizontally and keep focus'))
				end
			})
		end
	},
	{
		"akinsho/bufferline.nvim",
		lazy = false,
		version = "v3.*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
		end
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" },
		lazy = true,
		init = function()
			-- Find file
			vim.api.nvim_create_user_command("Ff", "Telescope find_files", {})
			-- Find text
			vim.api.nvim_create_user_command("Ft", 'lua require("telescope").extensions.live_grep_args.live_grep_args()',
				{})
		end,
		cmd = { "Telescope" },
		config = function()
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
		end
	},
	"nvim-telescope/telescope-live-grep-args.nvim",
	{
		"folke/trouble.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		lazy = true,
		init = function()
			vim.api.nvim_create_user_command("E", "TroubleToggle", {})
		end,
		cmd = { "TroubleToggle" },
		config = function()
			require("trouble").setup({})
		end
	},
	-- { "akinsho/toggleterm.nvim", version = "*",                               config = true },
	-- "L3MON4D3/LuaSnip",
	"hrsh7th/cmp-nvim-lsp",
	{
		"SirVer/ultisnips",
		config = function()
			vim.cmd("call UltiSnips#RefreshSnippets()")
		end
	},
	"quangnguyen30192/cmp-nvim-ultisnips",
	-- "saadparwaiz1/cmp_luasnip",
	"MunifTanjim/prettier.nvim",
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	ft = "markdown",
	-- 	build = function()
	-- 		vim.fn["mkdp#util#install"]()
	-- 	end,
	-- },
	-- { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	-- "numToStr/Comment.nvim",
	-- You need "im-select" executable on Mac
	-- https://github.com/daipeihust/im-select
	-- ```
	-- # If you use Intel chip on your Mac, change 'apple' to 'intel' in the following code:
	-- sudo curl -L -o /usr/local/bin/im-select https://github.com/daipeihust/im-select/raw/master/im-select-mac/out/apple/im-select
	-- sudo chmod 755 /usr/local/bin/im-select
	-- ```
	-- "keaising/im-select.nvim",
	-- "unblevable/quick-scope",
	-- "haya14busa/vim-edgemotion",
	-- "phaazon/hop.nvim",
	{
		"karb94/neoscroll.nvim",
		lazy = true,
		keys = { "<C-u>", "<C-d>", "zt", "zz", "zb" },
		config = function()
			require("neoscroll").setup({
				mappings = { "<C-u>", "<C-d>", "zt", "zz", "zb" },
				hide_cursor = false,
			})
		end
	},
	{
		"zbirenbaum/copilot.lua",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	{
		dir = "~/settings-mac/.config/nvim/lua/im-select.lua",
		-- You need "im-select" executable on Mac
		-- https://github.com/daipeihust/im-select
		-- ```
		-- # If you use Intel chip on your Mac, change 'apple' to 'intel' in the following code:
		-- sudo curl -L -o /usr/local/bin/im-select https://github.com/daipeihust/im-select/raw/master/im-select-mac/out/apple/im-select
		-- sudo chmod 755 /usr/local/bin/im-select
		-- ```
		lazy = true,
		event = "InsertEnter",
		config = function()
			require("im-select").setup()
		end
	},
	{
		dir = "~/settings-mac/.config/nvim/lua/following-cursor.lua",
		lazy = true,
		keys = {
			{ "<C-_>",   mode = { "n", "i", "x" } },
			{ "<TAB>",   mode = { "n", "i", "x" } },
			{ "<S-TAB>", mode = { "n", "i", "x" } },
			{ "<C-i>",   mode = { "n", "i", "x" } },
			{ "<C-o>",   mode = { "n", "i", "x" } },
		},
		config = function()
			require("following-cursor").setup()
			vim.keymap.set({ 'n', 'i' }, '<C-_>', '<Plug>(following_cursor_toggle_comment_normal)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'x' }, '<C-_>', '<Plug>(following_cursor_toggle_comment_visual)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'n', 'i' }, '<TAB>', '<Plug>(following_cursor_shift_right_normal)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'n', 'i' }, '<C-i>', '<Plug>(following_cursor_shift_right_normal)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'n', 'i' }, '<S-TAB>', '<Plug>(following_cursor_shift_left_normal)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'n', 'i' }, '<C-o>', '<Plug>(following_cursor_shift_left_normal)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'x' }, '<TAB>', '<Plug>(following_cursor_shift_right_visual)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'x' }, '<C-i>', '<Plug>(following_cursor_shift_right_visual)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'x' }, '<S-TAB>', '<Plug>(following_cursor_shift_left_visual)',
				{ noremap = true, silent = true })
			vim.keymap.set({ 'x' }, '<C-o>', '<Plug>(following_cursor_shift_left_visual)',
				{ noremap = true, silent = true })
		end,
	},
}, {
	defaults = {
		-- lazy = true,
		lazy = false,
	},
	dev = {
		path = "~/settings-mac/.config/nvim/lua",
	},
})

vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- require("nvim-treesitter.configs").setup({
-- 	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "typescript" },
-- 	auto_install = false,
-- 	highlight = {
-- 		enable = true,
-- 		disable = function(_, buf)
-- 			local max_filesize = 100 * 1024 -- 100 KB
-- 			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
-- 			if ok and stats and stats.size > max_filesize then
-- 				return true
-- 			end
-- 		end,
-- 	},
-- })

--------------------------------------------------
--------------------------------------------------
-- OTHER SETTINGS
--------------------------------------------------
--------------------------------------------------

-- require("Comment").setup({
-- 	-- sticky = false,
-- })
-- vim.keymap.set("n", "<C-_>", "<Plug>(comment_toggle_linewise_current)")
-- vim.keymap.set("x", "<C-_>", "<Plug>(comment_toggle_linewise_visual)")



-- Usage:
-- <TAB> -> preview
-- q     -> close window



vim.opt.termguicolors = true





vim.o.mouse = "a"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.number = true
vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = ">>>"
vim.o.statusline = "%F%=%l/%L lines (%p%%)"
vim.o.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true

vim.api.nvim_create_user_command("Stg", "edit $MYVIMRC", {})

-- CHEAT SEAT
-- :so % <- source current file (useful when you develop plugin in lua or vimscript)
-- :noh <- turn off syntax hilight
-- :only <- close all other windows

vim.keymap.set({ "n" }, "<C-w>i", "<C-i>")
vim.keymap.set({ "n" }, "<C-w>o", "<C-o>")

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
vim.keymap.set("n", "<C-w>d", ":bn | bd# | BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-w>D", ":BufferLineCloseRight<CR>")
vim.keymap.set("n", "<C-w>j", ":wincmd w<CR>")
vim.keymap.set("n", "<C-w>k", ":wincmd W<CR>")
vim.keymap.set("n", "<C-w>h", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-w>l", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-w>H", ":BufferLineMovePrev<CR>")
vim.keymap.set("n", "<C-w>L", ":BufferLineMoveNext<CR>")
-- vim.keymap.set("n", "<C-w>w", ":vert res +25<CR>")
-- vim.keymap.set("n", "<C-w>W", ":vert res -25<CR>")
-- vim.keymap.set("n", "<C-w>t", ":res +15<CR>")
-- vim.keymap.set("n", "<C-w>T", ":res -15<CR>")
-- vim.keymap.set("n", "<C-w>=", ":horizontal wincmd =<CR>")
