local export = { "nvim-tree/nvim-tree.lua" }

export.dependencies = {
	{
		"nvim-lua/plenary.nvim", -- for custom plugin
	},
}

export.lazy = true

export.init = function()
	---@param find_file boolean
	local toggle_tree = function(find_file)
		local api = require("nvim-tree.api")
		if api.tree.is_tree_buf() then
			api.tree.close()
		else
			api.tree.open({ find_file = find_file })
		end
	end

	vim.keymap.set({ "n" }, "<Leader>f", function()
		toggle_tree(true)
	end, {})
	vim.keymap.set({ "n" }, "<Leader>F", function()
		toggle_tree(false)
	end, {})
end

local WIDTH = 30

export.config = function()
	local nvim_tree = require("nvim-tree")
	local nvim_tree_api = require("nvim-tree.api")
	local preview = require("custom.nvim-tree.preview")

	local is_root_node = function(node)
		local RootNode = require("nvim-tree.node.root")
		return node:as(RootNode) ~= nil
	end

	preview.setup({
		preview_buf_keymaps = {
			{
				key = "o",
				callback = preview.watch,
			},
			{
				key = "<ESC>",
				callback = preview.exit,
			},
			{
				key = "q",
				callback = preview.exit,
			},
			{
				key = "<CR>",
				callback = function()
					preview.exit()
					nvim_tree_api.node.open.edit()
				end,
			},
			{
				key = "O",
				callback = function()
					preview.exit()
					nvim_tree_api.node.open.edit()
					nvim_tree_api.tree.focus()
				end,
			},
		},
	})

	nvim_tree.setup({
		view = {
			width = WIDTH,
		},
		on_attach = function(bufnr)
			local function opts(desc)
				return {
					desc = "nvim-tree: " .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true,
				}
			end

			vim.keymap.set("n", "<CR>", nvim_tree_api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "<2-LeftMouse>", nvim_tree_api.node.open.edit, opts("Open"))
			vim.keymap.set("n", "o", function()
				local node = nvim_tree_api.tree.get_node_under_cursor()
				if node.type == "directory" then
					if not is_root_node(node) then
						nvim_tree_api.node.open.edit(node)
					end
				elseif not preview.is_watch_mode() then
					preview.watch()
				else
					preview.enter()
				end
			end, opts("Preview"))
			vim.keymap.set("n", "O", function()
				nvim_tree_api.node.open.edit()
				nvim_tree_api.tree.focus()
			end, opts("Open keeping focus on tree"))
			vim.keymap.set("n", "<ESC>", function()
				preview.exit()
			end, opts("Exit preview"))
			vim.keymap.set("n", "q", function()
				preview.exit()
			end, opts("Exit preview"))
			vim.keymap.set("n", "g", function()
				nvim_tree_api.tree.change_root(vim.fn.getcwd(-1))
			end, opts("Restore root directory"))
			vim.keymap.set("n", "x", nvim_tree_api.fs.cut, opts("Cut"))
			vim.keymap.set("n", "c", nvim_tree_api.fs.copy.node, opts("Copy"))
			vim.keymap.set("n", "y", nvim_tree_api.fs.copy.node, opts("Copy"))
			vim.keymap.set("n", "p", nvim_tree_api.fs.paste, opts("Paste"))
			vim.keymap.set("n", "v", nvim_tree_api.fs.paste, opts("Paste"))
			vim.keymap.set("n", "d", nvim_tree_api.fs.remove, opts("Delete"))
			vim.keymap.set("n", "r", nvim_tree_api.fs.rename, opts("Rename"))
			vim.keymap.set("n", "a", nvim_tree_api.fs.create, opts("Create"))
			vim.keymap.set("n", "<C-v>", nvim_tree_api.node.open.vertical, opts("Open vertically"))
			vim.keymap.set("n", "/", nvim_tree_api.node.open.vertical, opts("Open vertically"))
			vim.keymap.set("n", "?", function(node)
				nvim_tree_api.node.open.vertical(node)
				nvim_tree_api.tree.focus()
			end, opts("Open vertically and keep focus"))
			vim.keymap.set("n", "-", nvim_tree_api.node.open.horizontal, opts("Open horizontally"))
			vim.keymap.set("n", "<C-s>", nvim_tree_api.node.open.horizontal, opts("Open horizontally"))
			vim.keymap.set("n", "_", function(node)
				nvim_tree_api.node.open.horizontal(node)
				nvim_tree_api.tree.focus()
			end, opts("Open horizontally and keep focus"))
			vim.keymap.set("n", "<Esc>", function()
				nvim_tree_api.tree.close()
				nvim_tree_api.tree.toggle({
					find_file = false,
					focus = false,
				})
			end, opts("Leave focus from tree"))
		end,
	})
end

return export
