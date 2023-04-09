vim.o.scrolloff = 10
vim.o.wrap = true
vim.o.showbreak = '>>>'
vim.o.statusline = '%F%=%l/%L lines (%p%%)'

vim.api.nvim_create_user_command('Sv', 'source $MYVIMRC', {})

vim.api.nvim_set_keymap('', '<C-g>', '<ESC>', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-g>', '<ESC>', {noremap = true})
vim.api.nvim_set_keymap('', '<C-f>', '<Right>', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-f>', '<Right>', {noremap = true})
vim.api.nvim_set_keymap('', '<C-b>', '<Left>', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-b>', '<Left>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-n>', 'gj', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-n>', '<Down>', {noremap = true})
vim.api.nvim_set_keymap('', '<C-p>', 'gk', {noremap = true})
vim.api.nvim_set_keymap('!', '<C-p>', '<Up>', {noremap = true})
vim.api.nvim_set_keymap('n', 'J', 'j<C-e>', {noremap = true})
vim.api.nvim_set_keymap('n', 'K', 'k<C-y>', {noremap = true})

vim.api.nvim_set_keymap('n', '<C-w>/', ':below vsplit<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>-', ':below split<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>c', ':close<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>D', ':bn | bd#<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>j', ':wincmd w<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>k', ':wincmd W<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>h', ':bprev<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>l', ':bnext<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>w', ':vert res +25<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>W', ':vert res -25<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>t', ':res +15<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>T', ':res -15<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-w>=', ':horizontal wincmd =<CR>', {noremap = true})
