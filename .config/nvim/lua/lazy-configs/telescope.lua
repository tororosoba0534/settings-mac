local export = { "nvim-telescope/telescope.nvim" }

export.dependencies = {
	"nvim-lua/plenary.nvim",
	"nvim-telescope/telescope-live-grep-args.nvim",
	"nvim-telescope/telescope-file-browser.nvim",
	-- {
	-- 	"nvim-telescope/telescope-smart-history.nvim",
	-- 	dependencies = {
	-- 		-- You neen sqlite3 executable on your machine.
	-- 		"kkharji/sqlite.lua"
	-- 	},
	-- },
}

export.lazy = true

export.cmd = { "Telescope" }

export.init = function()
	-- Find file

	vim.api.nvim_create_user_command("F", function()
		require("telescope.builtin").find_files()
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("FF", function()
		require("telescope.builtin").find_files({
			cwd = require("telescope.utils").buffer_dir(),
		})
	end, { nargs = 0 })

	-- Find text

	vim.api.nvim_create_user_command("T", function()
		require("telescope.builtin").live_grep({
			glob_pattern = "!.git",
		})
	end, { nargs = 0 })

	vim.api.nvim_create_user_command("TT", function()
		require("telescope.builtin").live_grep({
			cwd = require("telescope.utils").buffer_dir(),
			glob_pattern = "!.git",
		})
	end, { nargs = 0 })

	vim.keymap.set({ "n" }, "<Leader>t", function()
		local text = vim.fn.expand("<cword>")
		require("telescope.builtin").live_grep({
			default_text = text,
			glob_pattern = "!.git",
		})
	end, {})

	vim.keymap.set({ "x" }, "<Leader>t", function()
		local text = require("utils.selection-getter").get_texts()[1]
		vim.cmd("noh") -- Workaround for deleting remained selection highlight
		require("telescope.builtin").live_grep({
			default_text = text,
			glob_pattern = "!.git",
		})
	end, {})

	vim.keymap.set({ "n" }, "<Leader>T", function()
		local text = require("utils.selection-getter").get_texts()[1]
		vim.cmd("noh") -- Workaround for deleting remained selection highlight
		require("telescope.builtin").live_grep({
			cwd = require("telescope.utils").buffer_dir(),
			default_text = text,
			glob_pattern = "!.git",
		})
	end, {})

	vim.keymap.set({ "x" }, "<Leader>T", function()
		local text = vim.fn.expand("<cword>")
		require("telescope.builtin").live_grep({
			cwd = require("telescope.utils").buffer_dir(),
			default_text = text,
			glob_pattern = "!.git",
		})
	end, {})

	-- Find help page

	vim.keymap.set("n", "<Leader>h", function()
		local floating_help = require("utils.floating-help")
		if floating_help:is_open() then
			floating_help:close()
		elseif floating_help:is_buf_loaded() then
			floating_help:open()
		else
			require("custom.telescope").float_help_page({})
		end
	end, {})

	vim.keymap.set("n", "<Leader>H", function()
		require("custom.telescope").float_help_page({})
	end, {})

	-- Open note

	vim.keymap.set("n", "<Leader>n", function()
		local dir = string.format("%s/notes/%s/%s/%s", os.getenv("HOME"), os.date("%Y"), os.date("%m"), os.date("%d"))
		require("telescope").extensions.file_browser.file_browser({
			path = dir,
		})
	end, {})
end

export.config = function()
	local telescope = require("telescope")
	telescope.load_extension("live_grep_args")
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
					["<C-s>"] = actions.select_horizontal,
					["<C-v>"] = actions.select_vertical,
				},
				n = {
					-- ["<S-TAB>"] = actions.cycle_history_next,
					-- ["<C-w>f"] = actions.close,
					["<C-s>"] = actions.select_horizontal,
					["<C-v>"] = actions.select_vertical,
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
			file_browser = {
				hijack_netrw = true,
			},
		},
	})
	telescope.load_extension("file_browser")
end

return export
