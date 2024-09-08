local export = {}

export.dir = "~/settings-mac/.config/nvim/lua/im-select.lua"
-- 	Originai: keaising/im-select.nvim
-- You need "im-select" executable on Mac
-- https://github.com/daipeihust/im-select
-- ```
-- # If you use Intel chip on your Mac, change 'apple' to 'intel' in the following code:
-- sudo curl -L -o /usr/local/bin/im-select https://github.com/daipeihust/im-select/raw/master/im-select-mac/out/apple/im-select
-- sudo chmod 755 /usr/local/bin/im-select
-- ```
export.lazy = true

export.event = "InsertEnter"

export.config = function()
	require("im-select").setup()
end

return export
