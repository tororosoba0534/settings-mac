--------------------------------------------------
--------------------------------------------------
-- BASIC SETTINGS
--------------------------------------------------
--------------------------------------------------
-- CHEAT SEAT
-- :so % <- source current file (useful when you develop plugin in lua or vimscript)
-- :noh <- turn off syntax hilight
-- :only <- close all other windows

-- Disable netrw at the very start of your init.lua
-- Strongly recommended when you use nvim-tree.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- -- DO NOT set below option.
-- -- since the location of python3 executable differs between Intel Mac and M1 Mac.
-- -- If you are in trouble of python3 provider, please make sure your pip version is latest.
-- vim.g.python3_host_prog = "/usr/local/bin/python3"

-- Options
vim.opt.completeopt = { "menu", "menuone", "noselect" }
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
-- vim.o.cursorline = true
-- vim.o.cursorcolumn = true
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true

-- Commands and key mappings
vim.g.mapleader = " "

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

-- Window management
vim.keymap.set("n", "<C-w>/", ":below vsplit<CR>")
vim.keymap.set("n", "<C-w>-", ":below split<CR>")
vim.keymap.set("n", "<C-w>c", ":close<CR>")
vim.keymap.set("n", "<C-w>C", ":only<CR>")
vim.keymap.set("n", "<Leader>C", ":only<CR>")
vim.keymap.set("n", "<C-w>d", ":bn | bd# | bn<CR>")
vim.keymap.set("n", "<C-w>D", ":BufferLineCloseRight<CR>")
vim.keymap.set("n", "<C-w>j", ":wincmd w<CR>")
vim.keymap.set("n", "<C-w>k", ":wincmd W<CR>")
vim.keymap.set("n", "<C-w>h", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-w>l", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-w>H", ":BufferLineMovePrev<CR>")
vim.keymap.set("n", "<C-w>L", ":BufferLineMoveNext<CR>")

vim.api.nvim_create_user_command("Stg", "edit $MYVIMRC", {})
vim.api.nvim_create_user_command("Hl", function()
	if vim.o.cursorline then
		vim.o.cursorline = false
		vim.o.cursorcolumn = false
	else
		vim.o.cursorline = true
		vim.o.cursorcolumn = true
	end
end, {})
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
	{ "folke/lazy.nvim" },

	--------------------
	-- COMPLETION
	--------------------
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			"hrsh7th/cmp-nvim-lsp",
			{
				"zbirenbaum/copilot-cmp",
				config = function()
					require("copilot_cmp").setup()
				end,
				dependencies = {
					{
						"zbirenbaum/copilot.lua",
						config = function()
							require("copilot").setup({
								suggestion = { enabled = false },
								panel = { enabled = false },
							})
						end
					},
				}
			},
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
			},
			'saadparwaiz1/cmp_luasnip',
		},
		lazy = true,
		-- lazy = false,
		event = { "InsertEnter" },
		config = function()
			local cmp = require("cmp")
			cmp.setup.global({
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = {
					['<CR>'] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						selec = true,
					}),
					['<C-p>'] = cmp.mapping.select_prev_item(),
					['<C-n>'] = cmp.mapping.select_next_item(),
					['<Up>'] = cmp.mapping.select_prev_item(),
					['<Down>'] = cmp.mapping.select_next_item(),
				},
				sources = {
					{
						name = "buffer",
						option = {
							-- Avoid dealing with huge buffers
							get_bufnrs = function()
								local buf = vim.api.nvim_get_current_buf()
								local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
								if byte_size > 1024 * 1024 then -- 1 Megabyte max
									return {}
								end
								return { buf }
							end
						},
					},
					{ name = "path", },
					-- { name = "copilot", group_index = 2 },
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
				},
			})
			cmp.setup.cmdline("/", {
				mapping = {
					['<C-n>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							else
								fallback()
							end
						end,
					},
					['<C-p>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							else
								fallback()
							end
						end,
					},
					['<Up>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							else
								fallback()
							end
						end,
					},
					['<Down>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							else
								fallback()
							end
						end,
					},
					['<TAB>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.close()
							else
								cmp.complete()
							end
						end,
					},
				},
				sources = {
					{ name = "buffer" },
				},
			})
			cmp.setup.cmdline(":", {
				mapping = {
					['<C-n>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							else
								fallback()
							end
						end,
					},
					['<C-p>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							else
								fallback()
							end
						end,
					},
					['<Up>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_next_item()
							else
								fallback()
							end
						end,
					},
					['<Down>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.select_prev_item()
							else
								fallback()
							end
						end,
					},
					['<TAB>'] = {
						c = function(fallback)
							if cmp.visible() then
								cmp.close()
							else
								cmp.complete()
							end
						end,
					},
				},
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignoer_cmds = { "Man", "!" }
						},
					}
				}),
				completion = {
					autocomplete = false
				},
			})
		end,
	},
	--------------------
	-- Language Servers Management
	--------------------
	{
		'williamboman/mason.nvim',
		dependencies = {
			'williamboman/mason-lspconfig.nvim',
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		cmd = "Mason",
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"jsonls",
					"tsserver",
					"html",
					"cssls",
					"pyright",
					"graphql",
					"kotlin_language_server",
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
	},
	--------------------
	-- LSP
	--------------------
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ 'antosha417/nvim-lsp-file-operations' },
			-- 'williamboman/mason-lspconfig.nvim',
		},
		init = function()
			-- Set PATH for language servers installed by mason.nvim.
			-- This settings is executed in setup function of mason.nvim,
			-- but mason.nvim is so heavy that it is loaded lazily,
			-- then we need set PATH explicitly here.
			-- Path separator ":" might not work on Windows.
			vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.expand("$HOME") .. "/.local/share/nvim/mason/bin"
			local opts = { noremap = true, silent = true }

			opts.desc = "Show documentation for what is under cursor"
			vim.keymap.set("n", "gh", function()
				vim.lsp.buf.hover()
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
		end,
		config = function()
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
			lspconfig["tsserver"].setup({
				capabilities = capabilities,
				filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
			})
			lspconfig["lua_ls"].setup({
				capabilities = capabilities,
				settings = { -- custom settings for lua
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- make language server aware of runtime files
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})
		end
	},
	--------------------
	-- Formatters
	--------------------
	{
		'stevearc/conform.nvim',
		lazy = true,
		event = { "TextChanged" },
		config = function()
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
		end,
	},

	--------------------
	-- Others
	--------------------
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
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-live-grep-args.nvim",
			-- {
			-- 	"nvim-telescope/telescope-smart-history.nvim",
			-- 	dependencies = {
			-- 		-- You neen sqlite3 executable on your machine.
			-- 		"kkharji/sqlite.lua"
			-- 	},
			-- },
		},
		lazy = true,
		init = function()
			-- Find file
			vim.keymap.set('n', '<Leader>f', "<CMD>Telescope find_files<CR>", {})
			-- Find text
			vim.keymap.set('n', '<Leader>t', "<CMD>TelescopeLiveGrepArgs<CR>", {})
			-- Find help page
			vim.keymap.set('n', '<Leader>h', '<CMD>Telescope help_tags<CR>', {})
			-- Find buffer
			vim.keymap.set('n', '<Leader>b', '<CMD>TelescopeMyBuffers!<CR>', {})
		end,
		cmd = { "Telescope", "TelescopeLiveGrepArgs", "TelescopeMyBuffers" },
		config = function()
			local telescope = require("telescope")
			require("telescope").load_extension("live_grep_args")
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			telescope.setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git" },
					mappings = {
						i = {
							-- ["<TAB>"] = actions.cycle_history_prev,
							-- ["<S-TAB>"] = actions.cycle_history_next,
							-- ["<esc>"] = telescope_actions.close,
							-- ["<C-g>"] = telescope_actions.close,
							-- ["q"] = telescope_actions.close,
						},
						n = {
							-- ["<S-TAB>"] = actions.cycle_history_next,
							-- ["<C-w>f"] = actions.close,
							["<esc>"] = actions.close,
							["<C-g>"] = actions.close,
							["q"] = actions.close,
						},
					},
					history = {
						-- path = vim.fn.expand("$HOME") .. '/.local/share/nvim/databases/telescope_history.sqlite3',
						limit = 100,
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
				extensions = {
					live_grep_args = {},
				},
			})

			vim.api.nvim_create_user_command("TelescopeMyBuffers", function(opts)
				local entering_normal_mode = opts.bang
				require("telescope.builtin").buffers {
					on_complete = { function()
						if entering_normal_mode then
							vim.cmd("stopinsert")
						end
					end },
					attach_mappings = function(_, map)
						local delete_selected_buffers = function(_prompt_bufnr)
							local base_bufnr = vim.fn.bufnr('#')
							local deleting_base_buffer = false
							local current_picker = action_state.get_current_picker(_prompt_bufnr)
							current_picker:delete_selection(function(selection)
								if selection.bufnr == base_bufnr then
									deleting_base_buffer = true
								else
									vim.api.nvim_buf_delete(selection.bufnr, { force = false })
								end
							end)
							if deleting_base_buffer then
								actions.close(_prompt_bufnr)
								vim.api.nvim_buf_delete(base_bufnr, { force = false })
								vim.cmd("TelescopeMyBuffers!")
							end
						end
						map({ "n" }, "<TAB>", actions.toggle_selection)
						map({ "n" }, "d", delete_selected_buffers)
						map({ "n" }, "D", function(_prompt_bufnr)
							actions.add_selection(_prompt_bufnr)
							actions.toggle_all(_prompt_bufnr)
							delete_selected_buffers(_prompt_bufnr)
						end)
						return true
					end,
				}
			end, { bang = true })
			vim.api.nvim_create_user_command("TelescopeLiveGrepArgs",
				require("telescope").extensions.live_grep_args.live_grep_args, {})
		end
	},
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
		dir = "~/settings-mac/.config/nvim/lua/im-select.lua",
		-- 	Originai: keaising/im-select.nvim
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
		-- TODO: load when TAB is pressed in the insert mode

		-- init = function()
		-- 	vim.keymap.set({ 'n', 'i' }, '<TAB>', '<Plug>(following_cursor_shift_right_normal)',
		-- 		{ noremap = true, silent = true })
		-- end,
		lazy = true,
		event = "InsertEnter",
		keys = {
			-- { '<Plug>(following_cursor_shift_right_normal)', mode = "i" },
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
	{
		dir = "~/settings-mac/.config/nvim/lua/nvim-window.lua",
		lazy = true,
		keys = { '<Leader><Leader>', '<Leader>c' },
		config = function()
			require('nvim-window').setup({
			})
			vim.keymap.set({ 'n' }, '<Leader><Leader>', require('nvim-window').pick,
				{ noremap = true, silent = true })
			vim.keymap.set({ 'n' }, '<Leader>c', require('nvim-window').close,
				{ noremap = true, silent = true })
		end,

	},
}, {
	defaults = {
		lazy = true,
	},
	dev = {
		path = "~/settings-mac/.config/nvim/lua",
	},
})
