local loader = require('lazy-configs.nvim-tree.preview.loader')

---@class WinMgr
local WinMgr = {
	win = nil,
	buf = nil,
}

-- TODO: get current tree width dynamically
local TREE_WIDTH = 30

local get_win_opts = function()
	local height = math.ceil(vim.o.lines * 2 / 3)
	return {
		relative = 'win',
		width = math.min(vim.o.columns - TREE_WIDTH, 100),
		height = height,
		row = 5,
		col = TREE_WIDTH + 1,
	}
end

function WinMgr:update_win_opts()
	if not self.win or not vim.api.nvim_win_is_valid(self.win) then
		return
	end
	vim.api.nvim_win_set_config(self.win, get_win_opts())
end

-- TODO: Place keymap definition in appropriate place
---@type Keymap[]
local keymaps = {
	{
		key = 'o',
		callback = function()
			require('lazy-configs.nvim-tree.preview.mode-manager'):to_watch_mode()
		end,
	},
	{
		key = 'O',
		callback = function()
			require('lazy-configs.nvim-tree.preview.mode-manager'):to_tree_mode()
		end,
	},
}

---@param node Node
---@param focus_preview boolean
function WinMgr:show(node, focus_preview)
	if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
		vim.api.nvim_buf_delete(self.buf, { force = true })
	end
	self.buf = vim.api.nvim_create_buf(false, true)
	vim.schedule(function()
		loader.load(node, self.buf)
	end)
	if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
		self.win = vim.api.nvim_open_win(self.buf, focus_preview, get_win_opts())
	else
		vim.api.nvim_win_set_buf(self.win, self.buf)
		self:update_win_opts()
		if focus_preview then
			vim.api.nvim_set_current_win(self.win)
		end
	end
	self:_set_keymap(keymaps)
end

function WinMgr:close()
	if self.win ~= nil and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, true)
	end
	if self.buf ~= nil and vim.api.nvim_buf_is_valid(self.buf) then
		vim.api.nvim_buf_delete(self.buf, { force = true })
	end
	self.win = nil
	self.buf = nil
end

---@param buf number?
---@return boolean
function WinMgr:is_preview_buf(buf)
	return self.buf == buf
end

---@param keymaps Keymap[]
function WinMgr:_set_keymap(keymaps)
	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		return
	end
	for _, keymap in ipairs(keymaps) do
		vim.api.nvim_buf_set_keymap(self.buf, 'n', keymap.key, '', {
			noremap = true,
			callback = keymap.callback,
			desc = 'exit enter mode'
		})
	end
end

function WinMgr:focus_preview()
	if self.win and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_set_current_win(self.win)
	end
end

return WinMgr
