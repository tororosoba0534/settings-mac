local loader = require('lazy-configs.nvim-tree.preview.loader')

---@class WinMgr
local WinMgr = {
	win = nil,
	buf = nil,
}

---@param node Node
function WinMgr:show(node)
	self.buf = vim.api.nvim_create_buf(false, true)
	vim.schedule(function()
		loader.load(node, self.buf)
	end)
	if self.win == nil or not vim.api.nvim_win_is_valid(self.win) then
		self.win = vim.api.nvim_open_win(self.buf, false, {
			-- TODO: improve window optinos
			relative = 'win',
			width = 100,
			height = 10,
			row = math.max(0, vim.fn.screenrow() - 1),
			col = vim.fn.winwidth(0) + 1
		})
	else
		vim.api.nvim_win_set_buf(self.win, self.buf)
	end
end

function WinMgr:close()
	if self.win ~= nil and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, true)
	end
	self.win = nil
	self.buf = nil
end

---@param buf number?
---@return boolean
function WinMgr:is_preview_buf(buf)
	return self.buf == buf
end

return WinMgr
