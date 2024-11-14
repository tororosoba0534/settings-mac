---@class FloatHelp
---@field private win number?
---@field private buf number?
---@field private hl_ns number?
local FloatHelp = {
	win = nil,
	buf = nil,
	hl_ns = nil,
}

function FloatHelp:inspect()
	local value = {
		win = self.win,
		buf = self.buf,
		hl_ns = self.hl_ns,
	}
	print(vim.inspect(value))
end

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

	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) or term ~= nil then
		self.buf = vim.api.nvim_create_buf(false, true)
	end
	vim.bo[self.buf].buftype = "help"
	vim.bo[self.buf].swapfile = false

	if term ~= nil then
		vim.api.nvim_buf_call(self.buf, function()
			vim.cmd('help ' .. term)
		end)
	end

	local ui = vim.api.nvim_list_uis()[1]
	local width = math.floor(ui.width / 2)
	local height = math.floor(ui.height * 2 / 3)

	self.win = vim.api.nvim_open_win(self.buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((ui.width / 2) - (width / 2)),
		row = math.floor((ui.height / 2) - (height / 2)),
		anchor = "NW",
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		title = "    " .. vim.fs.basename(vim.api.nvim_buf_get_name(self.buf)) .. "    ",
		title_pos = "center",
	})

	self.hl_ns = vim.api.nvim_create_namespace('floating-help')
	vim.api.nvim_set_hl(self.hl_ns, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(self.hl_ns, "FloatBorder", { bg = "none", fg = '#ffffff' })
	vim.api.nvim_set_hl(self.hl_ns, "FloatTitle", { bg = "none", fg = '#ffffff' })
	vim.api.nvim_win_set_hl_ns(self.win, self.hl_ns)

	vim.cmd('setlocal number')
end

function FloatHelp:close()
	if self.win and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_close(self.win, true)
	end

	self.win = nil
end

return FloatHelp
