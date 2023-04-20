local notetaking = {}

local function is_dot_in_path(path)
	return path:match("(.*%.)") and true or false
end

local function is_md_file(path)
	local suffix = path:sub(-3)
	return suffix == ".md" and true or false
end

local function get_dir_path(path)
	return path:match("(.*[/\\])") or ""
end

local function does_dir_exists(dir)
	if dir == "" then
		return true
	elseif vim.fn.finddir(dir) == "" then
		return false
	end
	return true
end

local function does_file_exists(file)
	if vim.fn.findfile(file) == "" then
		return false
	end
	return true
end

local function is_absolute_path(path)
	local head = string.sub(path, 1, 1)
	if head == "/" or head == "~" then
		return true
	end
	return false
end

local function split_string_into_table(input_str, sep)
	if not sep then
		sep = "%s"
	end
	local result = {}
	for str in string.gmatch(input_str, "([^" .. sep .. "]+)") do
		table.insert(result, str)
	end
	return result
end

local function abs_table_to_rel_table(orig, dest)
	local i_max = math.min(#orig, #dest)
	-- print("i_max: " .. tostring(i_max))

	local i_common = 0
	for i = 1, i_max do
		if orig[i] ~= dest[i] then
			break
		end
		i_common = i_common + 1
	end
	-- print("i_common: " .. tostring(i_common))
	--
	local result = {}
	local double_dots = #orig - i_common - 1
	if double_dots == 0 then
		table.insert(result, ".")
	else
		for _ = 1, double_dots, 1 do
			table.insert(result, "..")
		end
	end

	for i = i_common + 1, #dest, 1 do
		table.insert(result, dest[i])
	end

	return result
end

local function rel_table_to_abs_table(orig_abs, dest_rel)
	local result = {}

	local i_single_dots = dest_rel[1] == "." and 1 or 0
	local i_double_dots = 0
	while dest_rel[i_double_dots + 1] == ".." do
		i_double_dots = i_double_dots + 1
	end

	for i = 1, #orig_abs - i_double_dots - 1 do
		result[i] = orig_abs[i]
	end
	local i_dest_start = i_single_dots + i_double_dots + 1
	for i = i_dest_start, #dest_rel do
		table.insert(result, dest_rel[i])
	end
	return result
end

local function concat_table_to_string(input_table, sep)
	local result = table.concat(input_table, sep)
	return result
end

function notetaking.get_file_tail(path)
	local path_table = split_string_into_table(path, "/")
	local tail = path_table[#path_table]
	return tail
end

function notetaking.path_rel_to_abs(orig_abs, dest_rel)
	local orig_abs_table = split_string_into_table(orig_abs, "/")
	local dest_rel_table = split_string_into_table(dest_rel, "/")
	local dest_abs_table = rel_table_to_abs_table(orig_abs_table, dest_rel_table)
	local dest_abs = concat_table_to_string(dest_abs_table, "/")
	return "/" .. dest_abs
end

function notetaking.path_abs_to_rel(orig_abs, dest_abs)
	local orig_abs_table = split_string_into_table(orig_abs, "/")
	local dest_abs_table = split_string_into_table(dest_abs, "/")
	local dest_rel_table = abs_table_to_rel_table(orig_abs_table, dest_abs_table)
	local dest_rel = concat_table_to_string(dest_rel_table, "/")
	return dest_rel
end

function notetaking.main()
	local dest_rel = vim.fn.expand("<cfile>")
	local is_md_dest = is_md_file(dest_rel)
	local is_abs = is_absolute_path(dest_rel)
	local has_double_dot = (dest_rel):sub(1, 2) == ".."
	local orig_abs = vim.fn.expand("%:p")
	local is_md_orig = is_md_file(orig_abs)
	local dest_abs = notetaking.path_rel_to_abs(orig_abs, dest_rel)
	local dest_abs_dir = get_dir_path(dest_abs)
	local exists_dir = does_dir_exists(dest_abs_dir)
	local exists_file = does_file_exists(dest_abs)

	-- local test_msg = ""
	-- test_msg = test_msg .. "dest_rel: " .. dest_rel .. ",\n"
	-- test_msg = test_msg .. "is_abs: " .. tostring(is_abs) .. ",\n"
	-- test_msg = test_msg .. "orig_abs: " .. orig_abs .. ",\n"
	-- test_msg = test_msg .. "dest_abs: " .. dest_abs .. ",\n"
	-- test_msg = test_msg .. "dest_abs_dir: " .. dest_abs_dir .. ",\n"
	-- test_msg = test_msg .. "exists_dir: " .. tostring(exists_dir) .. ",\n"
	-- test_msg = test_msg .. "exists_file: " .. tostring(exists_file) .. ",\n"
	-- test_msg = test_msg .. "is_md_dest: " .. tostring(is_md_dest) .. ",\n"
	-- test_msg = test_msg .. "is_md_orig: " .. tostring(is_md_orig) .. ",\n"
	--
	-- vim.notify(test_msg)

	if (not (is_md_dest and is_md_orig)) or is_abs or exists_file then
		if not pcall(function()
			vim.cmd('exe "norm! gf"')
		end) then
			print("File " .. dest_rel .. " does NOT exist.")
			return
		end
		-- print("normal gf executed")
		print("Go to file: " .. dest_abs)
		return
	end

	if not exists_dir then
		if has_double_dot then
			print("Directory " .. dest_abs_dir .. " does NOT exist.")
			return
		else
			vim.ui.input({
				prompt = "Directory "
					.. dest_abs_dir
					.. " and file "
					.. notetaking.get_file_tail(orig_abs)
					.. " does not exist.\n"
					.. "Create new directory and file? (if so, press y and Enter): ",
			}, function(input)
				if input == "y" then
					local orig_rel = notetaking.path_abs_to_rel(dest_abs, orig_abs)
					vim.cmd("!mkdir -p " .. dest_abs_dir .. '; echo "' .. orig_rel .. ' <- BACK" >> ' .. dest_abs)
					vim.cmd("find " .. dest_abs)
					print("New directory and file created: " .. dest_abs)
				else
					print("Cancelled.")
				end
			end)
			return
		end
	end

	vim.ui.input(
		{ prompt = "File " .. dest_abs .. " does not exist.\n" .. "Create new file? (if so, press y and Enter): " },
		function(input)
			if input == "y" then
				local orig_rel = notetaking.path_abs_to_rel(dest_abs, orig_abs)
				vim.cmd('!echo "' .. orig_rel .. ' <- BACK" >> ' .. dest_abs)
				vim.cmd("find " .. dest_abs)
				print("New file created: " .. dest_abs)
			else
				print("Cancelled.")
			end
		end
	)
end

function notetaking.test()
	local dest_rel = vim.fn.expand("<cfile>")
	local is_abs = is_absolute_path(dest_rel)
	local orig_abs = vim.fn.expand("%:p")
	local dest_abs = notetaking.path_rel_to_abs(orig_abs, dest_rel)
	local dest_abs_dir = get_dir_path(dest_abs)
	local exists_dir = does_dir_exists(dest_abs_dir)
	local exists_file = does_file_exists(dest_abs)
	-- local is_dir = does_dir_exists(dir)
	-- local is_file = does_file_exists(dest_rel)

	local result = "<dest_rel>: "
		.. dest_rel
		.. ",\n"
		.. "is_abs: "
		.. tostring(is_abs)
		.. ",\n"
		.. "orig_abs: "
		.. orig_abs
		.. ",\n"
		.. "dest_abs: "
		.. dest_abs
		.. ",\n"
		.. "dest_abs_dir: "
		.. dest_abs_dir
		.. ",\n"
		.. "exists_dir: "
		.. tostring(exists_dir)
		.. ",\n"
		.. "exists_file: "
		.. tostring(exists_file)
		.. ",\n"
	-- .. "is_dir: "
	-- .. tostring(is_dir)
	-- .. ",\n"
	-- .. "is_file: "
	-- .. tostring(is_file)
	-- .. ",\n"

	-- print(vim.inspect(result))
	vim.notify(result)
end

-- vim.keymap.set("n", "gb", function()
-- 	notetaking.main()
-- 	-- notetaking.test()
-- 	-- notetaking.path_abs_to_rel_test()
-- end)
-- -- notetaking.path_rel_to_abs_test()
-- -- notetaking.test()
return notetaking
