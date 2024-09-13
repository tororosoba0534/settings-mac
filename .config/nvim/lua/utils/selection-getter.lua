--- @return integer row_top The top of the selection (0-indexed)
--- @return integer row_bottom The bottom of the selection (0-indexed, exclusive)
local get_selection_rows_number = function()
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

return {
	--- @return integer row_top The top of the selection (0-indexed)
	--- @return integer row_bottom The bottom of the selection (0-indexed, exclusive)
	--- @return string[] lines The lines under selection
	get_lines = function()
		-- 0-indexed & end-exclusive indexing style
		local row_top, row_bottom = get_selection_rows_number()


		-- nvim_buf_get_line uses 0-indexed & end-exclusive indexing style
		local lines = vim.api.nvim_buf_get_lines(0, row_top, row_bottom, true)

		-- -- For debugging purpose
		-- error(vim.inspect(lines))

		return row_top, row_bottom, lines
	end,
}
