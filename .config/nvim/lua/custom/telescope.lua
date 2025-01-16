local export = {}

local core = function(opts, callback)
	local previewers = require("telescope.previewers")
	local conf = require("telescope.config").values
	local utils = require("telescope.utils")
	local Path = require("plenary.path")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local make_entry = require("telescope.make_entry")
	local action_set = require("telescope.actions.set")
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")

	opts.lang = vim.F.if_nil(opts.lang, vim.o.helplang)
	opts.fallback = vim.F.if_nil(opts.fallback, true)
	opts.file_ignore_patterns = {}

	local langs = vim.split(opts.lang, ",", { trimempty = true })
	if opts.fallback and not vim.tbl_contains(langs, "en") then
		table.insert(langs, "en")
	end
	local langs_map = {}
	for _, lang in ipairs(langs) do
		langs_map[lang] = true
	end

	local tag_files = {}
	local function add_tag_file(lang, file)
		if langs_map[lang] then
			if tag_files[lang] then
				table.insert(tag_files[lang], file)
			else
				tag_files[lang] = { file }
			end
		end
	end

	local help_files = {}
	local all_files = vim.api.nvim_get_runtime_file("doc/*", true)
	for _, fullpath in ipairs(all_files) do
		local file = utils.path_tail(fullpath)
		if file == "tags" then
			add_tag_file("en", fullpath)
		elseif file:match("^tags%-..$") then
			local lang = file:sub(-2)
			add_tag_file(lang, fullpath)
		else
			help_files[file] = fullpath
		end
	end

	local tags = {}
	local tags_map = {}
	local delimiter = string.char(9)
	for _, lang in ipairs(langs) do
		for _, file in ipairs(tag_files[lang] or {}) do
			local lines = utils.split_lines(Path:new(file):read(), { trimempty = true })
			for _, line in ipairs(lines) do
				-- TODO: also ignore tagComment starting with ';'
				if not line:match("^!_TAG_") then
					local fields = vim.split(line, delimiter, { trimempty = true })
					if #fields == 3 and not tags_map[fields[1]] then
						if fields[1] ~= "help-tags" or fields[2] ~= "tags" then
							table.insert(tags, {
								name = fields[1],
								filename = help_files[fields[2]],
								cmd = fields[3],
								lang = lang,
							})
							tags_map[fields[1]] = true
						end
					end
				end
			end
		end
	end

	pickers
		.new(opts, {
			prompt_title = "Help",
			finder = finders.new_table({
				results = tags,
				entry_maker = function(entry)
					return make_entry.set_default_entry_mt({
						value = entry.name .. "@" .. entry.lang,
						display = entry.name,
						ordinal = entry.name,
						filename = entry.filename,
						cmd = entry.cmd,
					}, opts)
				end,
			}),
			previewer = previewers.help.new(opts),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr)
				action_set.select:replace(function(_, cmd)
					local selection = action_state.get_selected_entry()
					if selection == nil then
						utils.__warn_no_selection("builtin.help_tags")
						return
					end

					actions.close(prompt_bufnr)
					-- if cmd == "default" or cmd == "horizontal" then
					-- 	vim.cmd("help " .. selection.value)
					-- elseif cmd == "vertical" then
					-- 	vim.cmd("vert help " .. selection.value)
					-- elseif cmd == "tab" then
					-- 	vim.cmd("tab help " .. selection.value)
					-- end
					callback(selection.value)
				end)

				return true
			end,
		})
		:find()
end

export.pick_help_page = function(opts)
	core(opts, function(term)
		require("help-wrapper").open_help(term)
	end)
end

export.float_help_page = function(opts)
	core(opts, function(term)
		require("utils.floating-help"):open(term)
	end)
end

return export
