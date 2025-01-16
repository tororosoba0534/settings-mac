--- @alias SelectionPosition { row: integer, col: integer }

--- @return SelectionPosition pos_start The start position of the selection
--- @return SelectionPosition pos_end The end position of the selection
--- 0-indexed & end-inclusive indexing style.
--- Top to Bottom (pos_start.row <= pos_end.row).
--- If on a row, left to right (pos_start.col <= pos_end.col).
local get_selection_positions = function()
	local cursor = {
		row = vim.api.nvim_win_get_cursor(0)[1] - 1,
		col = vim.api.nvim_win_get_cursor(0)[2],
	}

	local vstart = {
		row = vim.fn.line("v") - 1,
		col = vim.fn.col("v") - 1,
	}

	if vstart.row < cursor.row or (vstart.row == cursor.row and vstart.col <= cursor.col) then
		return vstart, cursor
	else
		return cursor, vstart
	end
end

----------------------------------------------------------------

--- @return integer row_top The top of the selection (0-indexed)
--- @return integer row_bottom The bottom of the selection (0-indexed, inclusive)
--- @return string[] lines The rows under selection
local get_rows = function()
	-- 0-indexed & end-exclusive indexing style
	local pos_start, pos_end = get_selection_positions()
	local row_top, row_bottom = pos_start.row, pos_end.row

	-- nvim_buf_get_line uses 0-indexed & end-exclusive indexing style
	local lines = vim.api.nvim_buf_get_lines(0, row_top, row_bottom + 1, true)

	--  -- For debugging purpose
	-- error(vim.inspect(lines))

	return row_top, row_bottom, lines
end

--- @return SelectionPosition pos_start The Top or the leftmost position of the selection
--- @return SelectionPosition pos_end The Bottom or the rightmost position of the selection
--- @return string[] selected The selected text arrays
local get_normal_selected = function()
	local pos_start, pos_end = get_selection_positions()
	local lines = vim.api.nvim_buf_get_lines(0, pos_start.row, pos_end.row + 1, true)

	local selected = {}

	if #lines == 1 then
		table.insert(selected, string.sub(lines[1], pos_start.col + 1, pos_end.col + 1))
		-- error(vim.inspect(selected))
		return pos_start, pos_end, selected
	end

	for i, line in ipairs(lines) do
		if i == 1 then
			table.insert(selected, string.sub(line, pos_start.col + 1))
		elseif i == #lines then
			table.insert(selected, string.sub(line, 1, pos_end.col + 1))
		else
			table.insert(selected, line)
		end
	end
	-- error(vim.inspect(selected))
	return pos_start, pos_end, selected
end

--- @return SelectionPosition pos_top_left The top-left corner of the selection
--- @return SelectionPosition pos_end The bottom-right corner of the selection
--- @return string[] selected The selected text arrays
local get_rectangle_selected = function()
	local pos_start, pos_end = get_selection_positions()
	local top_left = { row = pos_start.row, col = math.min(pos_start.col, pos_end.col) }
	local bottom_rignt = { row = pos_end.row, col = math.max(pos_start.col, pos_end.col) }

	local lines = vim.api.nvim_buf_get_lines(0, top_left.row, bottom_rignt.row + 1, true)
	local selected = {}
	for _, line in ipairs(lines) do
		table.insert(selected, string.sub(line, top_left.col + 1, bottom_rignt.col + 1))
	end

	-- error(vim.inspect(selected))
	return pos_start, pos_end, selected
end

-----------------------------------------------------------------------------

--- @return string[] texts The selected texts
local get_texts = function()
	local texts
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" then
		_, _, texts = get_normal_selected()
	elseif mode == "V" then
		_, _, texts = get_rows()
	else
		_, _, texts = get_rectangle_selected()
	end
	return texts
end

return {
	get_normal_selected = get_normal_selected,
	get_rectangle_selected = get_rectangle_selected,
	get_rows = get_rows,
	get_texts = get_texts,
}
