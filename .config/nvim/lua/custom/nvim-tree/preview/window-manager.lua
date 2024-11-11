local loader = require('custom.nvim-tree.preview.loader')
local config = require('custom.nvim-tree.preview.config')

---@class WinMgr
---@field private win number?
---@field private buf number?
local WinMgr = {
	win = nil,
	buf = nil,
}

-- TODO: get current tree width dynamically
local TREE_WIDTH = 30

---@private
local _get_win_opts = function()
	local height = math.ceil(vim.o.lines * 2 / 3)
	return {
		relative = 'win',
		width = math.min(vim.o.columns - TREE_WIDTH, 100),
		height = height,
		row = 5,
		col = TREE_WIDTH + 1,
	}
end

---@private
function WinMgr:_update_win_opts()
	if not self.win or not vim.api.nvim_win_is_valid(self.win) then
		return
	end
	vim.api.nvim_win_set_config(self.win, _get_win_opts())
end

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
		self.win = vim.api.nvim_open_win(self.buf, focus_preview, _get_win_opts())
	else
		vim.api.nvim_win_set_buf(self.win, self.buf)
		self:_update_win_opts()
		if focus_preview then
			vim.api.nvim_set_current_win(self.win)
		end
	end
	self:_set_keymap()
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

---@private
function WinMgr:_set_keymap()
	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		return
	end
	for _, keymap in ipairs(config:get_preview_buf_keymaps()) do
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
