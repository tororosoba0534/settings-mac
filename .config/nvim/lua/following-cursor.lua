----------------------------------------
-- UTILITY
----------------------------------------
local function core(func)
	local y, old_x = unpack(vim.api.nvim_win_get_cursor(0))
	local line_len_before = vim.api.nvim_get_current_line():len()

	func()

	local line_len_after = vim.api.nvim_get_current_line():len()
	local new_x = math.max(0, old_x + line_len_after - line_len_before)
	vim.api.nvim_win_set_cursor(0, { y, new_x })
end

local function get_selected_lines()
	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	local row_start = vstart[2] - 1
	local row_end = vend[2]
	local lines = vim.api.nvim_buf_get_lines(0, row_start, row_end, true)
	return row_start, row_end, lines
end

----------------------------------------
-- INDENT
----------------------------------------
local function get_indent_chars()
	if vim.o.expandtab then
		return string.rep(" ", vim.o.shiftwidth)
	end
	return "\t"
end

local function increase_indent_of_line(line, ignore_empty)
	if line == "" and ignore_empty then
		return ""
	else
		return get_indent_chars() .. line
	end
end

local function decrease_indent_of_line(line)
	if line == "" then
		return ""
	end
	local head = line:sub(1, 1)
	if head == "\t" then
		return line:sub(2)
	end
	head = line:sub(1, vim.o.shiftwidth)
	local indent_spaces = string.rep(" ", vim.o.shiftwidth)
	if vim.o.expandtab and head == indent_spaces then
		return line:sub(vim.o.shiftwidth + 1)
	end
	return line
end

local function shift_right_normal()
	core(function()
		local line = vim.api.nvim_get_current_line()
		local new_line = increase_indent_of_line(line, false)
		vim.api.nvim_set_current_line(new_line)
	end)
end

local function shift_left_normal()
	core(function()
		local line = vim.api.nvim_get_current_line()
		local new_line = decrease_indent_of_line(line)
		vim.api.nvim_set_current_line(new_line)
	end)
end

local function shift_right_visual()
	core(function()
		local row_start, row_end, lines = get_selected_lines()
		local new_lines = {}
		for _, line in pairs(lines) do
			local new_line = increase_indent_of_line(line, true)
			table.insert(new_lines, new_line)
		end
		vim.api.nvim_buf_set_lines(0, row_start, row_end, true, new_lines)
	end)
end

local function shift_left_visual()
	core(function()
		local row_start, row_end, lines = get_selected_lines()
		local new_lines = {}
		for _, line in pairs(lines) do
			local new_line = decrease_indent_of_line(line)
			table.insert(new_lines, new_line)
		end
		vim.api.nvim_buf_set_lines(0, row_start, row_end, true, new_lines)
	end)
end

----------------------------------------
-- COMMENT
----------------------------------------
local function escape_string(str)
	return (str:gsub('%%', '%%%%')
		:gsub('%^', '%%%^')
		:gsub('%$', '%%%$')
		:gsub('%(', '%%%(')
		:gsub('%)', '%%%)')
		:gsub('%.', '%%%.')
		:gsub('%[', '%%%[')
		:gsub('%]', '%%%]')
		:gsub('%*', '%%%*')
		:gsub('%+', '%%%+')
		:gsub('%-', '%%%-')
		:gsub('%?', '%%%?')
	)
end

local function get_raw_comment()
	local commentstring = vim.api.nvim_buf_get_option(0, "commentstring")
	local comment = string.gmatch(commentstring, "(.*)%%s")()
	return comment
end
local function remove_whitespace(str)
	return string.gsub(str, '%s+', '')
end

local function check_line(line)
	local escaped_spaceless_comment = escape_string(remove_whitespace(get_raw_comment()))
	local indent_area = string.gmatch(line, "(%s*)%S+")()
	local non_space_before_comment = string.gmatch(line, "(%S*)" .. escaped_spaceless_comment)()
	local i = indent_area == nil and 0 or indent_area:len() + 1
	local commented
	if non_space_before_comment == nil then
		-- There is no comment string
		commented = false
	elseif non_space_before_comment == "" then
		-- Comment string exists at the beginning of the line
		commented = true
	else
		-- There is uncommented keyword before the comment string
		commented = false
	end

	return i, commented
end

local function insert_string(base, part, pos)
	return base:sub(1, pos - 1) .. part .. base:sub(pos)
end

local function apply_comment(line, raw_comment, pos)
	local result = insert_string(line, raw_comment, pos)
	return result
end

local function remove_comment(line, escaped_comment)
	if line == "" then return "" end
	local left, right = string.gmatch(line, "(%s*)" .. escaped_comment .. "(.*)")()
	if left == nil or right == nil then
		left, right = string.gmatch(line, "(%s*)" .. remove_whitespace(escaped_comment) .. "(.*)")()
		if left == nil or right == nil then
			return line
		end
	end
	return left .. right
end

local function toggle_comment_normal_internal()
	local line = vim.api.nvim_get_current_line()
	local pos, commented = check_line(line)
	if commented then
		line = remove_comment(line, escape_string(get_raw_comment()))
	else
		line = apply_comment(line, get_raw_comment(), pos)
	end
	vim.api.nvim_set_current_line(line)
end

local function toggle_comment_visual_internal()
	local row_start, row_end, lines = get_selected_lines()

	local pos = nil
	local commented = true
	for _, line in pairs(lines) do
		local i, cmtd = check_line(line)

		-- `i == 0` means the line is empty.
		if i ~= 0 and (pos == nil or pos >= i) then
			pos = i
		end
		if i ~= 0 and cmtd == false then
			commented = false
		end
	end
	print("pos=" .. tostring(pos) .. ", commented=" .. tostring(commented))

	if pos == nil then
		return
	end

	local new_lines = {}
	if commented then
		for _, line in pairs(lines) do
			local new_line = line == "" and "" or
				remove_comment(line, escape_string(get_raw_comment()))
			table.insert(new_lines, new_line)
		end
	else
		for _, line in pairs(lines) do
			local new_line = line == "" and "" or apply_comment(line, get_raw_comment(), pos)
			table.insert(new_lines, new_line)
		end
	end
	vim.api.nvim_buf_set_lines(0, row_start, row_end, true, new_lines)
	-- vim.cmd("silent keepjumps normal! gv")
end

local function toggle_comment_normal()
	core(toggle_comment_normal_internal)
end

local function toggle_comment_visual()
	core(toggle_comment_visual_internal)
end

----------------------------------------
-- EXPORT
----------------------------------------
local M = {}

function M.setup()
	-- indent
	vim.keymap.set({ 'n', 'i' }, '<Plug>(following_cursor_shift_right_normal)', shift_right_normal,
		{ noremap = true, silent = true })
	vim.keymap.set({ 'n', 'i' }, '<Plug>(following_cursor_shift_left_normal)', shift_left_normal,
		{ noremap = true, silent = true })
	vim.api.nvim_create_user_command("FollowingCursorShiftRightVisualINTERNAL", shift_right_visual, {})
	vim.keymap.set({ 'x' }, '<Plug>(following_cursor_shift_right_visual)',
		'<ESC><CMD>lockmarks FollowingCursorShiftRightVisualINTERNAL<CR>',
		{ noremap = true, silent = true })
	vim.api.nvim_create_user_command("FollowingCursorShiftLeftVisualINTERNAL", shift_left_visual, {})
	vim.keymap.set({ 'x' }, '<Plug>(following_cursor_shift_left_visual)',
		'<ESC><CMD>lockmarks FollowingCursorShiftLeftVisualINTERNAL<CR>',
		{ noremap = true, silent = true })

	-- comment
	vim.keymap.set({ 'n', 'i' }, '<Plug>(following_cursor_toggle_comment_normal)', toggle_comment_normal,
		{ noremap = true, silent = true })
	vim.api.nvim_create_user_command("FollowingCursorToggleCommentVisualINTERNAL", toggle_comment_visual, {})
	vim.keymap.set({ 'x' }, '<Plug>(following_cursor_toggle_comment_visual)',
		'<ESC><CMD>lockmarks FollowingCursorToggleCommentVisualINTERNAL<CR>',
		{ noremap = true, silent = true })
end

return M
