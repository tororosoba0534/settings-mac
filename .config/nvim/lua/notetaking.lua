local notetaking = {}

local function is_dot_in_path(path)
	return path:match("(.*%.)") and true or false
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

function notetaking.test()
	local cfile = vim.fn.expand("<cfile>")
	local dir = get_dir_path(cfile)
	local is_dir = does_dir_exists(dir)
	local is_file = does_file_exists(cfile)

	local result = "<cfile>: "
		.. cfile
		.. ",\n"
		.. "dir: "
		.. dir
		.. ",\n"
		.. "is_dir: "
		.. tostring(is_dir)
		.. ",\n"
		.. "is_file: "
		.. tostring(is_file)
		.. ",\n"

	-- print(vim.inspect(result))
	vim.notify(result)
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

local function concat_table_to_string(input_table, sep)
	local result = table.concat(input_table, sep)
	return result
end

function notetaking.path_test()
	-- local orig_str = "/home/user1/settings-mac/.config/nvim/init.lua"
	-- local dest_str = "/home/user1/settings-mac/partial-links/README.md"

	local dest_str = "/home/user1/settings-mac/.config/nvim/init.lua"
	local orig_str = "/home/user1/settings-mac/partial-links/README.md"
	-- vim.notify(orig_str .. "\n" .. dest_str)
	-- print(orig_str)
	-- print(dest_str)

	local orig_table = split_string_into_table(orig_str, "/")
	local dest_table = split_string_into_table(dest_str, "/")
	-- vim.notify(vim.inspect(orig_table) .. "\n" .. vim.inspect(dest_table))
	-- vim.notify(vim.inspect({ "one", "two", "", "three" }))

	--
	local rel_table = abs_table_to_rel_table(orig_table, dest_table)
	-- vim.notify(vim.inspect(rel_table))
	local rel_str = concat_table_to_string(rel_table, "/")
	--
	print(rel_str)
	-- print("HELLO world")
end

-- function notetaking.main()
-- 	local path = vim.fn.expand("<cfile>")
--
-- 	if does_file_exists(path) then
-- 		print("Go to file: " .. path)
-- 		return
-- 	end
--
-- 	local dir = get_dir_path(path)
--
-- 	if not does_dir_exists(dir) then
-- 		print("Directory " .. dir .. " does NOT exists.")
-- 		return
-- 	elseif not is_dot_in_path(path) then
-- 		print("File " .. path .. " does NOT exists.")
-- 		return
-- 	end
--
-- 	vim.ui.input(
-- 		{ prompt = "File " .. path .. " does not exist.\n" .. "Create new file? (if so, press y and Enter): " },
-- 		function(input)
-- 			if input == "y" then
-- 				print("New file created: " .. path)
-- 			else
-- 				print("Cancelled.")
-- 			end
-- 		end
-- 	)
-- end

vim.keymap.set("n", "gb", function()
	-- notetaking.main()
	-- notetaking.test()
	notetaking.path_test()
end)
