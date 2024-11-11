local winmgr = require('lazy-configs.nvim-tree.preview.window-manager')

---@class Enterer
local Enterer = {
	augroup = nil,
	tree_buf = nil,
	tree_win = nil,
}

function Enterer:enter()
	if vim.bo.ft ~= 'NvimTree' then
		vim.notify('Cannot watch preview: current buffer is not NvimTree', vim.log.levels.ERROR)
		return
	end
	self.tree_buf = vim.api.nvim_get_current_buf()
	self.tree_win = vim.api.nvim_get_current_win()
	vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
		group = self.augroup,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			if buf ~= self.tree_buf and not winmgr:is_preview_buf(buf) then
				self:exit()
			end
		end,
	})
	self:_open_under_cursor()
end

function Enterer:_open_under_cursor()
	local ok, node = pcall(require('nvim-tree.api').tree.get_node_under_cursor)
	if ok and node then
		winmgr:show(node, true)
	end
end

function Enterer:exit()
	if self.augroup then
		vim.api.nvim_del_augroup_by_id(self.augroup)
	end
	if self.tree_win and vim.api.nvim_win_is_valid(self.tree_win) then
		vim.api.nvim_set_current_win(self.tree_win)
	end
	winmgr:close()

	self.augroup = nil
	self.tree_win = nil
end

return Enterer
