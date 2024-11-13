---@class FloatHelp
---@field private win number?
---@field private buf number?
local FloatHelp = {
	win = nil,
	buf = nil,
}

---@return boolean
function FloatHelp:is_open()
	return self.win ~= nil
end

---@return boolean
function FloatHelp:is_buf_loaded()
	return self.buf ~= nil
end

---@param term string?
function FloatHelp:open(term)
	if self:is_open() then
		self:close()
	end

	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		self.buf = vim.api.nvim_create_buf(false, true)
	end
	vim.bo[self.buf].buftype = "help"
	vim.bo[self.buf].swapfile = false

	local ui = vim.api.nvim_list_uis()[1]
	local width = 100
	local height = math.floor(ui.height * 2 / 3)

	self.win = vim.api.nvim_open_win(self.buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((ui.width / 2) - (width / 2)),
		row = math.floor((ui.height / 2) - (height / 2)),
		anchor = "NW",
	})

	if term ~= nil then
		vim.api.nvim_win_call(self.win, function()
			vim.cmd('help ' .. term)
		end)
	end
end

function FloatHelp:close()
	if self.win and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, true)
	end

	self.win = nil
end

return FloatHelp
