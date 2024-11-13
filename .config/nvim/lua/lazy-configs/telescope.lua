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
	vim.keymap.set({ 'n' }, '<Leader>f', function()
		require("telescope.builtin").find_files {
			cwd = require("telescope.utils").buffer_dir(),
		}
	end, {})
	vim.keymap.set({ 'n' }, '<Leader>F', function()
		require("telescope.builtin").find_files()
	end, {})
	-- Find text
	vim.keymap.set({ 'n' }, '<Leader>t', function()
		require("telescope.builtin").live_grep {
			cwd = require("telescope.utils").buffer_dir(),
			glob_pattern = '!.git',
		}
	end, {})
	vim.keymap.set({ 'x' }, '<Leader>t', function()
		local text = require('utils.selection-getter').get_texts()[1]
		vim.cmd("noh") -- Workaround for deleting remained selection highlight
		require("telescope.builtin").live_grep {
			cwd = require("telescope.utils").buffer_dir(),
			default_text = text,
			glob_pattern = '!.git',
		}
	end, {})
	vim.keymap.set({ 'n' }, '<Leader>T', function()
		require("telescope.builtin").live_grep {
			glob_pattern = '!.git',
		}
	end, {})
	vim.keymap.set({ 'x' }, '<Leader>T', function()
		local text = require('utils.selection-getter').get_texts()[1]
		vim.cmd("noh") -- Workaround for deleting remained selection highlight
		require("telescope.builtin").live_grep {
			default_text = text,
			glob_pattern = '!.git',
		}
	end, {})
	-- Find help page
	vim.keymap.set('n', '<Leader>h', function()
		local floating_help = require('utils.floating-help')
		if floating_help:is_open() then
			floating_help:close()
		elseif floating_help:is_buf_loaded() then
			floating_help:open()
		else
			require('custom.telescope').float_help_page {}
		end
	end, {})
	vim.keymap.set('n', '<Leader>H', function()
		require('custom.telescope').float_help_page {}
	end, {})
	-- Find buffer
	vim.keymap.set({ 'n' }, '<Leader>b', function()
		local actions = require("telescope.actions")
		require("telescope.builtin").buffers {
			attach_mappings = function(_, map)
				local delete_selected_buffers = function(_prompt_bufnr)
					local base_bufnr = vim.fn.bufnr('#')
					local deleting_base_buffer = false
					local current_picker = require("telescope.actions.state").get_current_picker(_prompt_bufnr)
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
	end, {})
end

export.config = function()
	local telescope = require("telescope")
	require("telescope").load_extension("live_grep_args")
	local actions = require("telescope.actions")
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
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
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
end

return export
