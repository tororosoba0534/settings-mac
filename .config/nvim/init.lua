-- Cheat sheet (default mappings)
--
-- <C-[>      Esc
--
-- -- Jump
-- <C-o>      Jump to older cursor position
-- <C-i>      Jump to newer cursor position
-- <C-]>      Jump to the definition of the keyword under the cursor.
-- <number>G  Jump to the line
--
-- -- LSP
-- K  Hover
--
-- -- netrw
-- :Ex                  Open netrw from current buffer's directory
-- :Vex                 Open netrw vertically from current buffer's directory
-- :e <directory-path>  Open netrw from current working directory
-- -- -- inside netrw
-- d  Create new directory
-- %  Create new file
-- D  Delete
-- R  Rename (can move)
-- -- -- -- mark
-- mf  Mark files
-- mt  Set target (if file, then its parent directory)
-- mm  Move marked files to target
-- mc  Copy marked files to target
--
-- -- Directory
-- !<shell-command>  Execute shell command
-- :pwd              Print working directory
-- :cd %:h           Change current directory to the current file's directory
--
-- -- Buffer
-- :e #         Edit previously edited buffer
-- :ls          Show a buffer list
-- :ls +        Show the list of the modified buffers
-- :b <number>  Select the buffer
-- :bd          Delete the buffer
-- :bw          Wipe out buffer (delete completely)
-- :%bw         Wipe out all the buffers
--
-- -- Window
-- <C-w>s (:sp)          Split horizontally
-- <C-w>v (:vs)          Split vertically
-- <C-w>q (:q)           Quit the current window
-- <C-w>c (:clo :close)  Close the current window
-- (<C-w>o) (:on :only)  Close the all windows other than the current window
-- <C-w>h j k l          Move to the window in the specified direction
-- <C-w>w (:winc w)      Choose the next window
-- <C-w>H J K L          Move current window to be at the far left, very bottom, very top, and the far right
-- :res <number>         Resize window's height
-- :vert res <number>    Resize window's width
--
-- -- Others
-- :so %           Source current file (useful when you develop plugin in lua or vimscript)
-- :noh            Turn off syntax hilight
-- :e ++enc=sjis   Reopen current file with encoding Shift_JIS
-- :e ++enc=utf-8  Reopen current file with encoding UTF-8

---------------------------------------
---------------------------------------
-- BASIC SETTINGS
---------------------------------------
---------------------------------------

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
vim.o.statusline = "%F %m (modified %{len(filter(getbufinfo(), 'v:val.changed == 1'))})%=%l/%L lines (%p%%)"
vim.o.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = 1000
-- For eliminating delays on ESC
vim.o.ttimeoutlen = 0

-- Commands and key mappings
vim.g.mapleader = " "

vim.keymap.set("n", "<C-w>o", function()
	print('<C-w>o is disabled. Please use `:on` if you wanna close other windows.')
end)

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

	-- Completion
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
			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end
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
					['<Tab>'] = vim.schedule_wrap(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end),
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

	-- Language Servers Management
	require('lazy-configs/mason'),

	-- LSP
	require('lazy-configs/nvim-lspconfig'),

	-- Formatters
	require('lazy-configs/conform'),

	-- Others
	require('lazy-configs/telescope'),
	require('lazy-configs/undotree'),
	require('lazy-configs/trouble'),
	require('lazy-configs/neoscroll'),
	require('lazy-configs/im-select'),
	require('lazy-configs/nvim-window'),
}, {
	defaults = {
		lazy = true,
	},
	dev = {
		path = "~/settings-mac/.config/nvim/lua",
	},
})
