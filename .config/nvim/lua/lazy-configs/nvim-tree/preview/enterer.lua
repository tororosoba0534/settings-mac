local winmgr = require('lazy-configs.nvim-tree.preview.window-manager')

---@class Enterer
local Enterer = {
	augroup = nil,
	tree_buf = nil,
	tree_win = nil,
}

---@type Keymap[]
local keymaps = {
	{
		key = 'O',
		callback = function()
			Enterer:exit(true)
		end,
	},
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
				self:exit(false)
			end
		end,
	})
	self:_open_under_cursor()
	winmgr:set_keymap(keymaps)
end

function Enterer:_open_under_cursor()
	local ok, node = pcall(require('nvim-tree.api').tree.get_node_under_cursor)
	if ok and node then
		winmgr:show(node, true)
	end
end

---@param focus_tree_if_possible boolean
function Enterer:exit(focus_tree_if_possible)
	if self.augroup then
		vim.api.nvim_del_augroup_by_id(self.augroup)
	end
	if focus_tree_if_possible then
		self:_focus_tree_if_possible()
	end
	winmgr:close()

	self.augroup = nil
	self.tree_buf = nil
	self.tree_win = nil
end

function Enterer:_focus_tree_if_possible()
	if self.tree_win and vim.api.nvim_win_is_valid(self.tree_win) then
		vim.api.nvim_set_current_win(self.tree_win)
	end
end

return Enterer
