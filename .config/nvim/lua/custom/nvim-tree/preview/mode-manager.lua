local winmgr = require("custom.nvim-tree.preview.window-manager")

---@alias Mode 'exit' | 'watch' | 'enter'

---@class ModeMgr
---@field private mode Mode
---@field private augroup integer?
---@field private tree_buf integer?
---@field private tree_win integer?
---@field private node Node?
local ModeMgr = {
	mode = "exit",
	augroup = nil,
	tree_buf = nil,
	tree_win = nil,
	node = nil,
}

---@param mode Mode
---@return boolean
function ModeMgr:is(mode)
	return self.mode == mode
end

function ModeMgr:to_exit_mode()
	if self:is("exit") then
		return
	end
	if self.augroup then
		vim.api.nvim_del_augroup_by_id(self.augroup)
	end
	winmgr:close()

	self.mode = "exit"
	self.augroup = nil
	self.tree_buf = nil
	self.tree_win = nil
	self.node = nil
end

function ModeMgr:to_watch_mode()
	if self:is("watch") then
		return
	elseif self:is("exit") then
		self:_setup_preview_win(false)
	else
		-- Focus tree window
		if self.tree_win and vim.api.nvim_win_is_valid(self.tree_win) then
			vim.api.nvim_set_current_win(self.tree_win)
		end
	end
	self.mode = "watch"
end

function ModeMgr:to_enter_mode()
	if self:is("enter") then
		return
	elseif self:is("exit") then
		self:_setup_preview_win(true)
	else
		winmgr:focus_preview()
	end
	self.mode = "enter"
end

---@private
---@param focus_preview boolean
function ModeMgr:_setup_preview_win(focus_preview)
	if vim.bo.ft ~= "NvimTree" then
		vim.notify("Cannot setup preview: current buffer is not NvimTree", vim.log.levels.ERROR)
		return
	end
	if not self:is("exit") then
		return
	end

	self.tree_buf = vim.api.nvim_get_current_buf()
	self.tree_win = vim.api.nvim_get_current_win()

	self.augroup = vim.api.nvim_create_augroup("nvim_tree_preview", { clear = true })
	vim.api.nvim_create_autocmd({ "CursorMoved" }, {
		group = self.augroup,
		buffer = self.tree_buf,
		callback = function()
			-- Don't focus preview window because this autocmd works only on watch mode
			self:_open_under_cursor(false)
		end,
	})
	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
		group = self.augroup,
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			if buf ~= self.tree_buf and not winmgr:is_preview_buf(buf) then
				self:to_exit_mode()
			end
		end,
	})
	self:_open_under_cursor(focus_preview)
end

---@private
---@param focus_preview boolean
function ModeMgr:_open_under_cursor(focus_preview)
	local ok, node = pcall(require("nvim-tree.api").tree.get_node_under_cursor)
	if ok and node and self:_has_node_changed(node) then
		self.node = node
		winmgr:show(node, focus_preview)
	end
end

---@private
---@param node Node
---@return boolean
function ModeMgr:_has_node_changed(node)
	return not self.node or node.absolute_path ~= self.node.absolute_path
end

return ModeMgr
