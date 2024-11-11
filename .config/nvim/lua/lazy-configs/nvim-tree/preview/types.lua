---@class Node
---@field type 'file' | 'directory' | 'link'
---@field name string
---@field absolute_path string

---@class Watcher
---@field augroup number?
---@field tree_buf number?
---@field node Node?

---@class Enterer
---@field augroup number?
---@field tree_buf number?
---@field tree_win number?

---@class WinMgr
---@field win number?
---@field buf number?

---@class Keymap
---@field key string
---@field callback function
