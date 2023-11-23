local main = {}

local function core(func)
	local y, old_x = unpack(vim.api.nvim_win_get_cursor(0))
	local line_len_before = vim.api.nvim_get_current_line():len()

	func()

	local line_len_after = vim.api.nvim_get_current_line():len()
	local new_x = math.max(0, old_x + line_len_after - line_len_before)
	vim.api.nvim_win_set_cursor(0, { y, new_x })
end

function main.shift_right()
	core(function()
		local str = vim.api.nvim_get_current_line()
		if str:len() == 0 then
			vim.api.nvim_set_current_line("	")
		else
			vim.cmd(string.format("silent keepjumps normal! %s>>", vim.v.count))
		end
	end)
end

function main.shift_left()
	core(function()
		vim.cmd(string.format("silent keepjumps normal! %s<<", vim.v.count))
	end)
end

return main
