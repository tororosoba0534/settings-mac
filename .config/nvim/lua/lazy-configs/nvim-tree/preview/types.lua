---@class Node
---@field type 'file' | 'directory' | 'link'
---@field name string
---@field absolute_path string

---@class Watcher
---@field augroup number?
---@field tree_buf number?
---@field node Node?

---@class WinMgr
---@field win number?
---@field buf number?
