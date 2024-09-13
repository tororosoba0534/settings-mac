--- @return string indent_string
local function get_indent_string()
	if vim.o.expandtab then
		return string.rep(' ', vim.o.shiftwidth)
	end
	return '\t'
end

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


--- @return integer row_top The top of the selection (0-indexed)
--- @return integer row_bottom The bottom of the selection (0-indexed, exclusive)
local get_selection_row_number = function()
	-- Cursor row (0-indexed, inclusive)
	local row_cursor = vim.api.nvim_win_get_cursor(0)[1] - 1

	-- Selection start row (0-indexed, inclusive)
	local row_vstart = vim.fn.line('v') - 1

	if row_cursor <= row_vstart then
		return row_cursor, row_vstart + 1
	else
		return row_vstart, row_cursor + 1
	end
end

--- @return integer row_top The top of the selection (0-indexed)
--- @return integer row_bottom The bottom of the selection (0-indexed, exclusive)
--- @return string[] lines The lines under selection
local get_lines = function()
	-- 0-indexed & end-exclusive indexing style
	local row_top, row_bottom = get_selection_row_number()


	-- nvim_buf_get_line uses 0-indexed & end-exclusive indexing style
	local lines = vim.api.nvim_buf_get_lines(0, row_top, row_bottom, true)

	-- -- For debugging purpose
	-- error(vim.inspect(lines))

	return row_top, row_bottom, lines
end

--- @param line_converter LineConverter
local function update_lines(line_converter)
	local y, x_old = unpack(vim.api.nvim_win_get_cursor(0))
	local line_len_before = vim.api.nvim_get_current_line():len()

	local row_start, row_end, lines = get_lines()

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

return {
	increase_indent = function()
		update_lines(line_converters.increase_indent)
	end,

	decrease_indent = function()
		update_lines(line_converters.decrease_indent)
	end,
}
