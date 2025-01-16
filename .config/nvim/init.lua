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

vim.o.mouse = "a"
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.number = true
vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = ">>>"
vim.o.guicursor = "i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150"
vim.cmd([[set clipboard+=unnamedplus]])
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.timeoutlen = 1000
-- For eliminating delays on ESC
vim.o.ttimeoutlen = 0

---------------------------------------
---------------------------------------
-- Syntax Highlight
---------------------------------------
---------------------------------------
vim.cmd([[colorscheme mine]])
vim.o.termguicolors = true

vim.o.statusline = "%F %m (modified %{len(filter(getbufinfo(), 'v:val.changed == 1'))})%=%l/%L lines (%p%%)"

vim.api.nvim_set_hl(0, "StatusLineIsModified", { bg = "firebrick1", bold = true })
vim.api.nvim_set_hl(0, "StatusLineIsNotModified", { reverse = true, bold = true })

-- local statusline =
-- 	"%{"
-- 	.. "len(filter(getbufinfo(), 'v:val.changed == 1')) == 0 ? "
-- 	.. "'%#StatusLineIsNotModified#no change'"
-- 	.. ":"
-- 	.. "'%#StatusLineIsModified#there exists modified buffer'"
-- 	.. "}"

-- local statusline = ""
-- 	.. "%#StatusLineIsNotModified#"
-- 	.. "%{"
-- 	.. "len(filter(getbufinfo(), 'v:val.changed == 1')) != 0 ? '' :"
-- 	.. "'there exists modified buffer'"
-- 	.. "}"
-- 	.. "%#StatusLineIsModified#"
-- 	.. "%{"
-- 	.. "len(filter(getbufinfo(), 'v:val.changed == 1')) == 0 ? '' :"
-- 	.. "'no change'"
-- 	.. "}"

-- local statusline = "%#StatusLineIsModified#here %#StatusLineIsNotModified#comes the sun"
-- vim.o.statusline = statusline

--
-- vim.cmd("set statusline+=%#StatusLineIsModified#%{len(filter(getbufinfo(), 'v:val.changed == 1'))==0?'':'%F %m (modified %{len(filter(getbufinfo(), %'v:val.changed == 1%'))})%=%l/%L lines (%p%%)'}")
-- vim.cmd("set statusline+=%#StatusLineIsNotModified#%{len(filter(getbufinfo(), 'v:val.changed ~= 1'))==0?'':'%F %m (modified %{len(filter(getbufinfo(), %'v:val.changed == 1%'))})%=%l/%L lines (%p%%)'}")

-- vim.api.nvim_set_hl(0, 'StatusLine', {bg = 'firebrick1'})

---------------------------------------
---------------------------------------
-- COMMANDS & KEYMAPS
---------------------------------------
---------------------------------------
vim.g.mapleader = " "

vim.keymap.set("n", "<C-w>o", function()
	print("<C-w>o is disabled. Please use `:on` if you wanna close other windows.")
end)

vim.api.nvim_create_user_command("H", function(opts)
	local page = opts.fargs[1] or ""
	require("help-wrapper").open_help(page)
end, {
	nargs = "?",
	bar = true,
	complete = "help",
})

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
	require("lazy-configs.luasnip"),

	-- Completion
	require("lazy-configs.nvim-cmp"),

	-- LSP
	require("lazy-configs.nvim-lspconfig"),

	-- Formatters
	require("lazy-configs.conform"),

	-- Other programs management
	require("lazy-configs.mason"),

	-- Others
	require("lazy-configs.telescope"),
	require("lazy-configs.undotree"),
	require("lazy-configs.nvim-tree"),
	require("lazy-configs.trouble"),
	require("lazy-configs.neoscroll"),
	require("lazy-configs.harpoon"),
}, {
	defaults = {
		lazy = true,
	},
})

-- local plugins
require("im-select").setup()

vim.keymap.set({ "i", "x" }, "<Tab>", require("indenter").increase, { noremap = true, silent = false })
vim.keymap.set({ "i", "x" }, "<S-Tab>", require("indenter").decrease, { noremap = true, silent = false })

require("nvim-window").setup({})
vim.keymap.set({ "n" }, "<Leader><Leader>", require("nvim-window").pick, { noremap = true, silent = true })
vim.keymap.set({ "n" }, "<Leader>c", require("nvim-window").close, { noremap = true, silent = true })
