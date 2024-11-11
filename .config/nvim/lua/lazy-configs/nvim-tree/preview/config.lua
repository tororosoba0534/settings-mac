---@class Keymap
---@field key string
---@field callback function

---@class Config
---@field private preview_buf_keymaps? Keymap[]
local Config = {}

---@param opts Config
function Config:set(opts)
	self.preview_buf_keymaps = opts.preview_buf_keymaps
end

---@return Keymap[] preview_buf_keymaps
function Config.get_preview_buf_keymaps()
	return Config.preview_buf_keymaps
end

return Config
