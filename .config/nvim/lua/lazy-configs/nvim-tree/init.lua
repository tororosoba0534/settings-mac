local export = { "nvim-tree/nvim-tree.lua" }

export.dependencies = {
	{
		'b0o/nvim-tree-preview.lua',
		'nvim-lua/plenary.nvim', -- for custom plugin
	},
}

export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("F", function()
		local api = require("nvim-tree.api")
		if api.tree.is_tree_buf() then
			api.tree.close()
		else
			api.tree.open()
		end
	end, { nargs = 0 })
end

local WIDTH = 30

export.config = function()
	local nvim_tree = require("nvim-tree")
	local nvim_tree_api = require("nvim-tree.api")
	nvim_tree.setup({
		view = {
			width = WIDTH,
		},
		on_attach = function(bufnr)
			local function opts(desc)
				return {
					desc = 'nvim-tree: ' .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true
				}
			end

			vim.keymap.set('n', '<CR>', nvim_tree_api.node.open.edit, opts('Open'))
			vim.keymap.set('n', '<2-LeftMouse>', nvim_tree_api.node.open.edit, opts('Open'))
			-- vim.keymap.set('n', 'o', function(node)
			-- 	nvim_tree_api.node.open.edit(node)
			-- 	nvim_tree_api.tree.focus()
			-- end, opts('Open and focus tree'))
			vim.keymap.set('n', 'o', function()
				local preview = require('lazy-configs.nvim-tree.preview')
				if preview.is_watching() then
					preview.unwatch()
				else
					preview.watch()
				end
			end, opts('Toggle preview watch'))
			vim.keymap.set('n', 'g', nvim_tree_api.tree.change_root_to_node, opts('Change root directory'))
			vim.keymap.set('n', 'x', nvim_tree_api.fs.cut, opts('Cut'))
			vim.keymap.set('n', 'c', nvim_tree_api.fs.copy.node, opts('Copy'))
			vim.keymap.set('n', 'y', nvim_tree_api.fs.copy.node, opts('Copy'))
			vim.keymap.set('n', 'p', nvim_tree_api.fs.paste, opts('Paste'))
			vim.keymap.set('n', 'v', nvim_tree_api.fs.paste, opts('Paste'))
			vim.keymap.set('n', 'd', nvim_tree_api.fs.remove, opts('Delete'))
			vim.keymap.set('n', 'r', nvim_tree_api.fs.rename, opts('Rename'))
			vim.keymap.set('n', 'a', nvim_tree_api.fs.create, opts('Create'))
			vim.keymap.set('n', '/', nvim_tree_api.node.open.vertical, opts('Open vertically'))
			vim.keymap.set('n', '?', function(node)
				nvim_tree_api.node.open.vertical(node)
				nvim_tree_api.tree.focus()
			end, opts('Open vertically and keep focus'))
			vim.keymap.set('n', '-', nvim_tree_api.node.open.horizontal, opts('Open horizontally'))
			vim.keymap.set('n', '_', function(node)
				nvim_tree_api.node.open.horizontal(node)
				nvim_tree_api.tree.focus()
			end, opts('Open horizontally and keep focus'))
		end,
	})

	local Path = require('plenary.path')

	vim.api.nvim_create_user_command("TEST", function(details)
		local path = details.fargs[1]

		-- print(path)

		Path:new(path):read(vim.schedule_wrap(function(data)
			print(data)
		end))
	end, { nargs = 1 })
end

return export
