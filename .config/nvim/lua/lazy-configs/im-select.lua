local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/im-select.lua"

export.lazy = true

export.event = "InsertEnter"

export.config = function()
	require("im-select").setup()
end

return export
