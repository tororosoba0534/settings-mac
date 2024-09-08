-- Original: keaising/im-select.nvim
--
-- You need `im-select` executable on your PC.
-- https://github.com/daipeihust/im-select
--
-- If you are in trouble, please check whether you have executable suitable for your cpu architecture.

local function all_trim(s)
	return s:match("^%s*(.-)%s*$")
end

local function get_os()
	if vim.fn.has("macunix") == 1 then
		return "macOS"
	elseif vim.fn.has("win32") == 1 then
		return "Windows"
	elseif vim.fn.has("wsl") == 1 then
		return "WSL"
	else
		return "Linux"
	end
end

local function is_supported()
	local os = get_os()
	-- macOS, Windows, WSL
	if os ~= "Linux" then
		return true
	end

	if vim.fn.executable("fcitx5-remote") then
		return true
	end
end

-- return type: {
--   command: im-select binary's name, or the binary's full path
--   input_method: default input method in normal mode.
-- }
local function get_config()
	local current_os = get_os()
	if current_os == "macOS" then
		return {
			command = "im-select",
			input_method = "com.apple.keylayout.ABC",
		}
	elseif current_os == "Windows" or current_os == "WSL" then
		return {
			-- WSL share same config with Windows
			command = "im-select.exe",
			input_method = "1033",
		}
	else
		return {
			-- fcitx5-remote -n: rime/keyboard-us
			-- fcitx5-remote -s rime
			-- fcitx5-remote -s keyboard-us
			command = "fcitx5-remote",
			input_method = "keyboard-us",
		}
	end
end

local function get_current_select(cmd)
	-- fcitx5 has its own parameters
	if cmd:find("fcitx5-remote", 1, true) ~= nil then
		return all_trim(vim.fn.system({ cmd, "-n" }))
	else
		return all_trim(vim.fn.system({ cmd }))
	end
end

local function change_im_select(cmd, method)
	if cmd:find("fcitx5-remote", 1, true) then
		print("change in im-select", cmd, method)
		return vim.fn.system({ cmd, "-s", method })
	else
		return vim.fn.system({ cmd, method })
	end
end

-----------------------------------------------------
-----------------------------------------------------

local export = {}

export.setup = function()
	if not is_supported() then
		return
	end

	local config = get_config()

	if vim.fn.executable(config.command) ~= 1 then
		vim.api.nvim_err_writeln(
			[[please install `im-select` binary first, repo url: https://github.com/daipeihust/im-select]]
		)
		return
	end

	-- set autocmd
	vim.api.nvim_create_autocmd({ "InsertEnter" }, {
		callback = function()
			local current_select = get_current_select(config.command)
			local save = vim.g["im_select_current_im_select"]

			if current_select ~= save then
				change_im_select(config.command, save)
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertLeave", "VimEnter" }, {
		callback = function()
			local current_select = get_current_select(config.command)
			vim.api.nvim_set_var("im_select_current_im_select", current_select)

			if current_select ~= config.input_method then
				change_im_select(config.command, config.input_method)
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "CmdlineLeave" }, {
		callback = function()
			change_im_select(config.command, config.input_method)
		end,
	})
end

return export
