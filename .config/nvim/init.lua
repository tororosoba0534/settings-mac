---------------------------------------
---------------------------------------
-- CHEAT SHEET (default mappings)
---------------------------------------
---------------------------------------
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
-- OPTIONS
---------------------------------------
---------------------------------------

-- -- DO NOT set below option.
-- -- since the location of python3 executable differs between Intel Mac and M1 Mac.
-- -- If you are in trouble of python3 provider, please make sure your pip version is latest.
-- vim.g.python3_host_prog = "/usr/local/bin/python3"

vim.opt.completeopt = { "menu", "menuone", "preview", "noselect" }
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
vim.cmd([[colorscheme vim]])

---------------------------------------
---------------------------------------
-- COMMANDS & KEYMAPS
---------------------------------------
---------------------------------------
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

if not vim.uv.fs_stat(lazypath) then
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

	-- Snippet
	require('lazy-configs.luasnip'),

	-- Completion
	require('lazy-configs.nvim-cmp'),

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
