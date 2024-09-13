local export = {}

--- @return string indent_string
local function get_indent_string()
	if vim.o.expandtab then
		return string.rep(' ', vim.o.shiftwidth)
	end
	return '\t'
end

--- @alias LineConverter fun(line_before: string): string


--- @type LineConverter[]
local line_converters = {
	--- @param line_before string line before increasing indent
	--- @return string line_after line after increasing indent
	increase_indent = function(line_before)
		return get_indent_string() .. line_before
	end,

	--- @param line_before string line before decreasing indent
	--- @return string line_after line after decreasing indent
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


--- @return integer row_start (zero-based)
--- @return integer row_end (zero-based, exclusive)
--- @return string[] lines
--- Zero-based and end-exclusive indexing style follows the specification of vim.api.nvim_buf_(get|set)_line.
local function get_lines()
	local mode = vim.api.nvim_get_mode().mode
	if mode ~= 'v' and mode ~= 'V' and mode ~= "CTRL-V" then
		local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
		return row - 1, row, { vim.api.nvim_get_current_line() }
	end

	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	local row_start = vstart[2]
	local row_end = vend[2]
	local lines = vim.api.nvim_buf_get_lines(0, row_start, row_end, true)
	return row_start, row_end, lines
end

--- @param line_converter LineConverter
local function update_lines(line_converter)
	local y, x_old = unpack(vim.api.nvim_win_get_cursor(0))
	local line_len_before = vim.api.nvim_get_current_line():len()

	local row_start, row_end, lines = get_lines()

	print('row_start:', row_start, 'row_end', row_end, 'first_lines:', lines[1], 'last_lines:', lines[#lines])

	--- @type string[]
	local new_lines = {}
	for _, line in ipairs(lines) do
		table.insert(new_lines, line_converter(line))
	end
	vim.api.nvim_buf_set_lines(0, row_start, row_end, true, new_lines)

	local line_len_after = vim.api.nvim_get_current_line():len()
	local x_new = math.max(0, x_old + line_len_after - line_len_before)
	vim.api.nvim_win_set_cursor(0, { y, x_new })
end

export.increase_indent = function()
	update_lines(line_converters.increase_indent)
end

export.decrease_indent = function()
	update_lines(line_converters.decrease_indent)
end

return export
