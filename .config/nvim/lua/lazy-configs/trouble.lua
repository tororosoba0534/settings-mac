local export = { "folke/trouble.nvim" }

export.dependencies = "nvim-tree/nvim-web-devicons"
export.lazy = true

export.init = function()
	vim.api.nvim_create_user_command("E", "TroubleToggleMyMenuCurrent", {})
	vim.api.nvim_create_user_command("Ea", "TroubleToggleMyMenuAll", {})
end

export.cmd = { "Trouble", "TroubleToggleMyMenuCurrent", "TroubleToggleMyMenuAll" }

export.config = function()
	local trouble = require("trouble")

	trouble.setup({
		modes = {
			current = {
				mode = "diagnostics",
				focus = true,
				preview = {
					type = "split",
					relative = "win",
					position = "right",
					size = 0.3,
				},
				filter = { buf = 0 },
			},
			all = {
				mode = "diagnostics",
				focus = true,
				preview = {
					type = "split",
					relative = "win",
					position = "right",
					size = 0.3,
				},
			},
		},
	})

	local toggle_current = function()
		if trouble.is_open("all") then
			trouble.close("all")
			trouble.open("current")
		else
			trouble.toggle("current")
		end
	end

	local toggle_all = function()
		if trouble.is_open("current") then
			trouble.close("current")
			trouble.open("all")
		else
			trouble.toggle("all")
		end
	end

	vim.api.nvim_create_user_command("TroubleToggleMyMenuCurrent", toggle_current, {})
	vim.api.nvim_create_user_command("TroubleToggleMyMenuAll", toggle_all, {})
end

return export
