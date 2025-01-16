---@class FloatHelp
---@field private win integer?
---@field private buf integer?
---@field private hl_ns integer?
---@field private augroup integer?
---@field private help_files any
local FloatHelp = {
	win = nil,
	buf = nil,
	hl_ns = nil,
	augroup = nil,
	help_files = require("utils.floating-help.utils").get_help_files(),
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
	return self.win ~= nil and vim.api.nvim_win_is_valid(self.win)
end

---@return boolean
function FloatHelp:is_buf_loaded()
	return self.buf ~= nil
end

---@return boolean
function FloatHelp:is_on_help()
	return self.help_files[vim.fs.basename(vim.api.nvim_buf_get_name(0))] ~= nil
end

---@param term string?
function FloatHelp:open(term)
	if self:is_open() then
		self:close()
	end

	if not self:is_buf_loaded() or term ~= nil then
		self.buf = vim.api.nvim_create_buf(false, true)
	end
	vim.bo[self.buf].buftype = "help"
	vim.bo[self.buf].swapfile = false

	local ui = vim.api.nvim_list_uis()[1]
	local width = math.floor(ui.width / 2)
	local height = math.floor(ui.height * 2 / 3)

	self.win = vim.api.nvim_open_win(self.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((ui.width / 2) - (width / 2)),
		row = math.floor((ui.height / 2) - (height / 2)),
		anchor = "NW",
		border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
		title = "    " .. vim.fs.basename(vim.api.nvim_buf_get_name(self.buf)) .. "    ",
		title_pos = "center",
	})

	self.hl_ns = vim.api.nvim_create_namespace("floating-help")
	vim.api.nvim_set_hl(self.hl_ns, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(self.hl_ns, "FloatBorder", { bg = "none", fg = "#ffffff" })
	vim.api.nvim_set_hl(self.hl_ns, "FloatTitle", { bg = "none", fg = "#ffffff" })
	vim.api.nvim_win_set_hl_ns(self.win, self.hl_ns)

	if term ~= nil then
		vim.cmd("help " .. term)
		self.buf = vim.fn.bufnr()
	end

	vim.cmd("setlocal number")

	self.augroup = vim.api.nvim_create_augroup("floating_help", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		group = self.augroup,
		callback = function()
			if self:is_on_help() then
				self.buf = vim.fn.bufnr()
			end
		end,
	})
end

function FloatHelp:close()
	if self:is_open() then
		vim.api.nvim_win_close(self.win, true)
	end

	if self.augroup then
		vim.api.nvim_del_augroup_by_id(self.augroup)
	end

	self.win = nil
	self.augroup = nil
end

return FloatHelp
