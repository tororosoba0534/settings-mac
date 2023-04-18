local stayinplace = {}

local function preserve(func)
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	local len_before = vim.api.nvim_get_current_line():len()
	local winview = vim.fn.winsaveview()

	func()

	vim.fn.winrestview(winview)
	local len_after = vim.api.nvim_get_current_line():len()
	local new_col = math.max(0, col - len_before + len_after)
	vim.api.nvim_win_set_cursor(0, { line, new_col })
end

function stayinplace.shift_right_line()
	preserve(function()
		vim.cmd(string.format("silent keepjumps normal! %s>>", vim.v.count))
	end)
end

function stayinplace.shift_left_line()
	preserve(function()
		vim.cmd(string.format("silent keepjumps normal! %s<<", vim.v.count))
	end)
end

return stayinplace
