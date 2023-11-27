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
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true

-- Commands and key mappings
vim.api.nvim_create_user_command("Stg", "edit $MYVIMRC", {})

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
vim.keymap.set("n", "<C-w>d", ":bn | bd# | BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-w>D", ":BufferLineCloseRight<CR>")
vim.keymap.set("n", "<C-w>j", ":wincmd w<CR>")
vim.keymap.set("n", "<C-w>k", ":wincmd W<CR>")
vim.keymap.set("n", "<C-w>h", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-w>l", ":BufferLineCycleNext<CR>")
vim.keymap.set("n", "<C-w>H", ":BufferLineMovePrev<CR>")
vim.keymap.set("n", "<C-w>L", ":BufferLineMoveNext<CR>")

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
	-- LSP settings
	--------------------
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
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
		},
		lazy = true,
		-- lazy = false,
		event = {"InsertEnter"},
		config = function()
			local cmp = require("cmp")
			cmp.setup.global({
				window = {
				  completion = cmp.config.window.bordered(),
				  documentation = cmp.config.window.bordered(),
				},
				mapping = {
					['<TAB>'] = cmp.mapping.confirm({
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
					{ name = "copilot", group_index = 2 },
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
	{
		'williamboman/mason.nvim',
		dependencies = {
			'williamboman/mason-lspconfig.nvim'
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"jsonls",
					"tsserver",
				},
				automatic_installation = true,
			})
		end
	},
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	event = {"BufReadPre", "BufNewFile"}
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-nvim-lsp",

	-- 	},
	-- },

	--------------------
	-- others
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
}, {
	defaults = {
		lazy = true,
		-- lazy = false,
	},
	dev = {
		path = "~/settings-mac/.config/nvim/lua",
	},
})
