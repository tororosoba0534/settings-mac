local export = { "nvim-tree/nvim-tree.lua" }

export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("F", "NvimTreeToggle", {})
	vim.api.nvim_create_user_command(
		'NvimTreeOpenTreeWithoutFocus',
		function()
			require("nvim-tree.api").tree.toggle({ focus = false })
		end,
		{ nargs = 0 }
	)
end

export.cmd = { "NvimTreeToggle", "NvimTreeOpenTreeWithoutFocus" }

export.config = function()
	local nvim_tree = require("nvim-tree")
	local nvim_tree_api = require("nvim-tree.api")
	nvim_tree.setup({
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
			vim.keymap.set('n', 'o', function(node)
				nvim_tree_api.node.open.edit(node)
				nvim_tree_api.tree.focus()
			end, opts('Open and focus tree'))
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
		end
	})
end

return export
