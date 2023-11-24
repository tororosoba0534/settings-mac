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
	-- print("comment=" .. comment)
	return comment
end
local function remove_whitespace(str)
	return string.gsub(str, '%s+', '')
end

-- :lua print(string.gmatch("\t\t\t-- hogefuga", "([%s\t]*)%-%-")():len())
-- :lua print(string.gmatch("\t\t\t hoge", "(%s*)%S+")():len())
local function check_line(line)
	local escaped_spaceless_comment = escape_string(remove_whitespace(get_raw_comment()))
	local indent_area = string.gmatch(line, "(%s*)%S+")()
	print("indent_area=" .. tostring(indent_area))
	local non_space_before_comment = string.gmatch(line, "(%S*)" .. escaped_spaceless_comment)()
	print("non_space_before_comment=" .. tostring(non_space_before_comment))
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

	print("i=" .. tostring(i) .. ", commented=" .. tostring(commented))
	return i, commented
end

local function insert_string(base, part, pos)
	return base:sub(1, pos - 1) .. part .. base:sub(pos)
end

local function apply_comment(line, raw_comment, pos)
	local result = insert_string(line, raw_comment, pos)
	print("result=" .. result)
	return result
end

local function remove_comment(line, escaped_spaceless_comment)
	local left, right = string.gmatch(line, "(.*)" .. escaped_spaceless_comment .. "%s*(.*)")()
	print("left=" .. tostring(left))
	print("right=" .. tostring(right))
	return left .. right
end



local function toggle_comment_line()
	local line = vim.api.nvim_get_current_line()
	local raw_comment = get_raw_comment()
	local match_string = "(.*)" .. escape_string(raw_comment) .. "(.*)"
	-- print("match_string=" .. match_string)
	local left, right = string.gmatch(line, match_string)()
	left = left == nil and "" or left
	right = right == nil and "" or right
	-- print("left=" .. left)
	-- print("right=" .. right)
	if left:len() == 0 and right:len() == 0 then
		vim.api.nvim_set_current_line(raw_comment .. line)
	else
		vim.api.nvim_set_current_line(left .. right)
	end
end

function main.toggle_comment_line()
	core(toggle_comment_line)
end

----------------------------------------
-- TEST
----------------------------------------

-- function main.test()
-- 	local commentstring = vim.api.nvim_buf_get_option(0, "commentstring")
-- 	local comment = string.gmatch(commentstring, "(.*)%%s")()
-- 	-- print("comment=" .. comment)
-- 	local escaped_comment = escape_string(comment)
-- 	-- print("escaped_comment=" .. escaped_comment)
-- 	local line = vim.api.nvim_get_current_line()
-- 	local match_string = "(.*)" .. escaped_comment .. "(.*)"
-- 	-- print("match_string=" .. match_string)
-- 	local left, right = string.gmatch(line, match_string)()
-- 	left = left == nil and "" or left
-- 	right = right == nil and "" or right
-- 	-- print("left=" .. left)
-- 	-- print("right=" .. right)
-- 	if left:len() == 0 and right:len() == 0 then
-- 		vim.api.nvim_set_current_line(comment .. line)
-- 	else
-- 		vim.api.nvim_set_current_line(left .. right)
-- 	end
-- end
--
-- return main
function main.test_n()
	-- toggle_comment_line()
	local line = vim.api.nvim_get_current_line()
	local pos, commented = check_line(line)
	if commented then
		line = remove_comment(line, escape_string(remove_whitespace(get_raw_comment())))
	else
		line = apply_comment(line, get_raw_comment(), pos)
	end
	vim.api.nvim_set_current_line(line)
	-- print("i=" .. tostring(i) .. ", b=" .. tostring(b))
end

function main.test_v()
	local vstart = vim.fn.getpos("'<")
	local vend = vim.fn.getpos("'>")
	local row_start = vstart[2]
	local row_end = vend[2]

	-- print("vstart=" .. vim.inspect(vstart))
	-- print("vend=" .. vim.inspect(vend))
	local lines = vim.api.nvim_buf_get_lines(0, row_start, row_end, true)
	for i, line in ipairs(lines) do
		print("line at " .. tostring(i) .. ": " .. line)
	end
end

return main
