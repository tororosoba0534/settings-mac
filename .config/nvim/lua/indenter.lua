--- @return string indent_string
local function get_indent_string()
	if vim.o.expandtab then
		return string.rep(' ', vim.o.shiftwidth)
	end
	return '\t'
end

--- @alias LineConverter fun(line_before: string): string

local line_converters = {
	--- @type LineConverter
	increase_indent = function(line_before)
		if line_before == '' then
			return ''
		end
		return get_indent_string() .. line_before
	end,

	--- @type LineConverter
	decrease_indent = function(line_before)
		if line_before == '' then
			return ''
		end

		local head = line_before:sub(1, 1)
		if head == '\t' then
			return line_before:sub(2)
		end

		head = line_before:sub(1, vim.o.shiftwidth)
		if vim.o.expandtab and head == string.rep(' ', vim.o.shiftwidth) then
			return line_before:sub(vim.o.shiftwidth + 1)
		end
		return line_before
	end,
}

--- @param line_converter LineConverter
local function update_lines(line_converter)
	local y, x_old = unpack(vim.api.nvim_win_get_cursor(0))
	local line_len_before = vim.api.nvim_get_current_line():len()

	local row_start, row_end, lines = require('utils.selection-getter').get_rows()

	--- @type string[]
	local new_lines = {}
	for _, line in ipairs(lines) do
		table.insert(new_lines, line_converter(line))
	end
	vim.api.nvim_buf_set_lines(0, row_start, row_end + 1, true, new_lines)

	local line_len_after = vim.api.nvim_get_current_line():len()
	local x_new = math.max(0, x_old + line_len_after - line_len_before)
	vim.api.nvim_win_set_cursor(0, { y, x_new })
end

return {
	increase = function()
		update_lines(line_converters.increase_indent)
	end,

	decrease = function()
		update_lines(line_converters.decrease_indent)
	end,
}
