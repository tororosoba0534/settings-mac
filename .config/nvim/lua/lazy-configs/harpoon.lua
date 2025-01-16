local export = {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}

export.init = function()
	vim.keymap.set({ "n" }, "<Leader>l", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
	end, {})
	vim.api.nvim_create_user_command("L", function()
		require("harpoon"):list():add()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
	end, {})
end

export.config = function()
	local harpoon = require("harpoon")
	harpoon:setup({
		settings = {
			save_on_toggle = true,
		},
	})
	harpoon:extend(require("harpoon.extensions").builtins.navigate_with_number())
	harpoon:extend({
		UI_CREATE = function(cx)
			vim.keymap.set("n", "/", function()
				harpoon.ui:select_menu_item({ vsplit = true })
			end, { buffer = cx.bufnr })

			vim.keymap.set("n", "-", function()
				harpoon.ui:select_menu_item({ split = true })
			end, { buffer = cx.bufnr })
		end,
	})
end

return export
