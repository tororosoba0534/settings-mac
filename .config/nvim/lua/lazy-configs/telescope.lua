local export = { "nvim-telescope/telescope.nvim" }

export.dependencies = {
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope-live-grep-args.nvim",
	-- {
	-- 	"nvim-telescope/telescope-smart-history.nvim",
	-- 	dependencies = {
	-- 		-- You neen sqlite3 executable on your machine.
	-- 		"kkharji/sqlite.lua"
	-- 	},
	-- },
}

export.lazy = true

export.init = function()
	-- Find file
	vim.keymap.set('n', '<Leader>f', "<CMD>Telescope find_files<CR>", {})
	-- Find text
	vim.keymap.set('n', '<Leader>t', "<CMD>TelescopeLiveGrepArgs<CR>", {})
	-- Find help page
	vim.keymap.set('n', '<Leader>h', '<CMD>TelescopeMyHelpPage<CR>', {})
	-- Find buffer
	vim.keymap.set('n', '<Leader>b', '<CMD>TelescopeMyBuffers!<CR>', {})
end

export.cmd = { "Telescope", "TelescopeLiveGrepArgs", "TelescopeMyBuffers", "TelescopeMyHelpPage" }

export.config = function()
	local telescope = require("telescope")
	require("telescope").load_extension("live_grep_args")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	telescope.setup({
		defaults = {
			file_ignore_patterns = { "node_modules", ".git" },
			mappings = {
				i = {
					-- ["<TAB>"] = actions.cycle_history_prev,
					-- ["<S-TAB>"] = actions.cycle_history_next,
					-- ["<esc>"] = telescope_actions.close,
					-- ["<C-g>"] = telescope_actions.close,
					-- ["q"] = telescope_actions.close,
				},
				n = {
					-- ["<S-TAB>"] = actions.cycle_history_next,
					-- ["<C-w>f"] = actions.close,
					["<esc>"] = actions.close,
					["<C-g>"] = actions.close,
					["q"] = actions.close,
				},
			},
			history = {
				-- path = vim.fn.expand("$HOME") .. '/.local/share/nvim/databases/telescope_history.sqlite3',
				limit = 100,
			},
		},
		pickers = {
			find_files = {
				hidden = true,
			},
		},
		extensions = {
			live_grep_args = {},
		},
	})

	vim.api.nvim_create_user_command("TelescopeMyBuffers", function(opts)
		local entering_normal_mode = opts.bang
		require("telescope.builtin").buffers {
			-- on_complete = { function()
			-- 	if entering_normal_mode then
			-- 		vim.cmd("stopinsert")
			-- 	end
			-- end },
			attach_mappings = function(_, map)
				local delete_selected_buffers = function(_prompt_bufnr)
					local base_bufnr = vim.fn.bufnr('#')
					local deleting_base_buffer = false
					local current_picker = action_state.get_current_picker(_prompt_bufnr)
					current_picker:delete_selection(function(selection)
						if selection.bufnr == base_bufnr then
							deleting_base_buffer = true
						else
							vim.api.nvim_buf_delete(selection.bufnr, { force = false })
						end
					end)
					if deleting_base_buffer then
						actions.close(_prompt_bufnr)
						vim.api.nvim_buf_delete(base_bufnr, { force = false })
						vim.cmd("TelescopeMyBuffers!")
					end
				end
				map({ "n" }, "<TAB>", actions.toggle_selection)
				map({ "n" }, "d", delete_selected_buffers)
				map({ "n" }, "D", function(_prompt_bufnr)
					actions.add_selection(_prompt_bufnr)
					actions.toggle_all(_prompt_bufnr)
					delete_selected_buffers(_prompt_bufnr)
				end)
				return true
			end,
		}
	end, { bang = true })
	vim.api.nvim_create_user_command("TelescopeLiveGrepArgs",
		require("telescope").extensions.live_grep_args.live_grep_args, {})
	vim.api.nvim_create_user_command("TelescopeMyHelpPage", function()
		require('custom.telescope').pick_help_page { default_text = vim.fn.expand('<cword>') }
	end, {})
end

return export
