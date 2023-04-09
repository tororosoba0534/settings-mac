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
	{ 'akinsho/bufferline.nvim', version = "v3.*", dependencies = 'nvim-tree/nvim-web-devicons' },
	-- fzf-lua
	-- You need "fzf" & "rg"
	{ 'ibhagwan/fzf-lua', dependencies = 'nvim-tree/nvim-web-devicons' },
	{'akinsho/toggleterm.nvim', version = "*", config = true},
	'neovim/nvim-lspconfig',
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate" -- :MasonUpdate updates registry contents
	},
	'williamboman/mason-lspconfig.nvim',
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
})


-- LSP settings
-- Setup order is important (https://github.com/williamboman/mason-lspconfig.nvim#setup):
-- 1. mason.nvim
-- 2. mason-lspconfig.nvim
-- 3. language server setups through nvim-lspconfig
--
require("mason").setup()
require("mason-lspconfig").setup()
-- Automatic server setup
-- If you use this approach, make sure you don't also manually set up servers directory via lspconfig as this will cause duplicated launches.
-- see :h mason-lspconfig-automatic-server-setup
require("mason-lspconfig").setup_handlers {
	function(server_name)
		require("lspconfig")[server_name].setup {}
	end,
	-- -- you can provide a dedicated handler for specific servers. for example:
	-- ["rust_analyzer"] = function ()
	--   require("rust-tools").setup {}
	-- end,
	["lua_ls"] = function()
		require("lspconfig").lua_ls.setup {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } }
				}
			}
		}
	end,
}

require('nvim-web-devicons').setup({})

require("nvim-tree").setup()
vim.api.nvim_set_keymap('n', '<M-f>', ':NvimTreeToggle<CR>', { noremap = true })

vim.api.nvim_set_keymap('n', '<M-S-f>', ':FzfLua files<CR>', { noremap = true })
vim.api.nvim_create_augroup("fzf", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
	pattern = {"fzf"},
	command = "tnoremap <buffer> <M-S-f> <ESC>",
})

vim.api.nvim_set_var('undotree_SetFocusWhenToggle', 1)
vim.api.nvim_set_keymap('n', '<M-u>', ':UndotreeToggle<CR>', { noremap = true })

require("toggleterm").setup{
	start_in_insert = false,
}
vim.keymap.set('n', '<M-t>', ':ToggleTerm<CR>i')
vim.keymap.set('t', '<M-t>', '<C-\\><C-n>:ToggleTerm<CR>')

vim.opt.termguicolors = true
require("bufferline").setup {}




vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = '>>>'
vim.o.statusline = '%F%=%l/%L lines (%p%%)'

vim.api.nvim_create_user_command('Sv', 'source $MYVIMRC', {})

vim.api.nvim_set_keymap('', '<C-g>', '<ESC>', { noremap = true })
vim.api.nvim_set_keymap('!', '<C-g>', '<ESC>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-f>', '<Right>', { noremap = true })
vim.api.nvim_set_keymap('!', '<C-f>', '<Right>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-b>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('!', '<C-b>', '<Left>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-n>', 'gj', { noremap = true })
vim.api.nvim_set_keymap('!', '<C-n>', '<Down>', { noremap = true })
vim.api.nvim_set_keymap('', '<C-p>', 'gk', { noremap = true })
vim.api.nvim_set_keymap('!', '<C-p>', '<Up>', { noremap = true })
vim.api.nvim_set_keymap('n', 'J', 'j<C-e>', { noremap = true })
vim.api.nvim_set_keymap('n', 'K', 'k<C-y>', { noremap = true })

vim.api.nvim_set_keymap('n', '<C-w>/', ':below vsplit<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>-', ':below split<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>c', ':close<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>D', ':bn | bd#<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>j', ':wincmd w<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>k', ':wincmd W<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>h', ':bprev<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>l', ':bnext<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>w', ':vert res +25<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>W', ':vert res -25<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>t', ':res +15<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>T', ':res -15<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-w>=', ':horizontal wincmd =<CR>', { noremap = true })
