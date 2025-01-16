local Path = require("plenary.path")

local path_tail = (function()
	local os_sep = Path.path.sep

	if os_sep == "/" then
		return function(path)
			for i = #path, 1, -1 do
				if path:sub(i, i) == os_sep then
					return path:sub(i + 1, -1)
				end
			end
			return path
		end
	else
		return function(path)
			for i = #path, 1, -1 do
				local c = path:sub(i, i)
				if c == os_sep or c == "/" then
					return path:sub(i + 1, -1)
				end
			end
			return path
		end
	end
end)()

return {
	get_help_files = function()
		local help_files = {}

		local rtp = vim.o.runtimepath
		-- extend the runtime path with all plugins not loaded by lazy.nvim
		local lazy = package.loaded["lazy.core.util"]
		if lazy and lazy.get_unloaded_rtp then
			local paths = lazy.get_unloaded_rtp("")
			if #paths > 0 then
				rtp = rtp .. "," .. table.concat(paths, ",")
			end
		end
		local all_files = vim.fn.globpath(rtp, "doc/*", true, 1)
		for _, fullpath in ipairs(all_files) do
			local file = path_tail(fullpath)
			if file ~= "tags" and not file:match("^tags%-..$") then
				help_files[file] = fullpath
			end
		end

		return help_files
	end,
}
