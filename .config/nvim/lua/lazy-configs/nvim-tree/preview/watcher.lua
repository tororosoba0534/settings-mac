local api = require('nvim-tree.api')
local winmgr = require('lazy-configs.nvim-tree.preview.window-manager')

---@class Watcher
local Watcher = {
	augroup = nil,
	tree_buf = nil,
	node = nil,
}

---@return boolean
function Watcher:is_watching()
	return self.augroup ~= nil
end

function Watcher:watch()
	if self.augroup then
		self:unwatch()
	end
	if vim.bo.ft ~= 'NvimTree' then
		vim.notify('Cannot watch preview: current buffer is not NvimTree', vim.log.levels.ERROR)
		return
	end
	self.augroup = vim.api.nvim_create_augroup('nvim_tree_preview_watch', { clear = true })
	self.tree_buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
		group = self.augroup,
		buffer = 0,
		callback = function()
			self:_open_under_cursor()
		end,
	})
	vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
		group = self.augroup,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			if buf ~= self.tree_buf and not winmgr:is_preview_buf(buf) then
				self:unwatch()
			end
		end,
	})
	self:_open_under_cursor()
end

function Watcher:_open_under_cursor()
	local ok, node = pcall(require('nvim-tree.api').tree.get_node_under_cursor)
	if ok and node and self:_has_node_changed(node) then
		self.node = node
		winmgr:show(node)
	end
end

---@return boolean
function Watcher:_has_node_changed(node)
	return not self.node or node.absolute_path ~= self.node.absolute_path
end

function Watcher:unwatch()
	if self.augroup then
		vim.api.nvim_del_augroup_by_id(self.augroup)
	end
	winmgr:close()
	self.augroup = nil
	self.tree_buf = nil
	self.node = nil
end

return Watcher
