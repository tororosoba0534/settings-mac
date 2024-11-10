local Path = require('plenary.path')

local Loader = {}

---@param buf number?
---@param content string[]
local set_content = function(buf, content)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
	vim.bo[buf].modifiable = false
end

local load_link = function(node, buf)
	local content = { node.name .. ' → ' .. node.link_to }
	set_content(buf, content)
end

---@param node Node
---@param before string[]
---@return string[] after
local format_directory_content = function(node, before)
	if not before or #before == 0 then
		return { 'Error reading directory' }
	end
	local files = vim.tbl_map(function(name)
		return {
			name = name,
			is_dir = vim.fn.isdirectory(node.absolute_path .. '/' .. name) == 1,
		}
	end, before)
	table.sort(files, function(a, b)
		if a.is_dir ~= b.is_dir then
			return a.is_dir
		end
		return a.name < b.name
	end)
	local after = { '  ' .. node.name .. '/' }
	for i, file in ipairs(files) do
		local prefix = i == #files and ' └ ' or ' │ '
		if file.is_dir then
			table.insert(after, prefix .. file.name .. '/')
		else
			table.insert(after, prefix .. file.name)
		end
	end
	return after
end

---@param node Node
---@param buf number?
local load_directory = function(node, buf)
	local content = vim.fn.readdir(node.absolute_path)
	local formatted = format_directory_content(node, content)
	set_content(buf, formatted)
end

---@param node Node
---@param buf number?
local load_file = function(node, buf)
	local path = node.absolute_path

	Path:new(path):read(vim.schedule_wrap(function(data)
		local content = vim.split(data, '[\r]?\n')
		if not content then
			content = { "" }
		end
		set_content(buf, content)
	end))
end


---@param node Node
---@param buf number?
function Loader.load(node, buf)
	if node.type == 'directory' then
		return load_directory(node, buf)
	elseif node.type == 'file' then
		return load_file(node, buf)
	elseif node.type == 'link' then
		return load_link(node, buf)
	else
		vim.notify('Unexpected node type: ' .. vim.inspect(node.type), vim.log.levels.ERROR)
	end
end

return Loader
