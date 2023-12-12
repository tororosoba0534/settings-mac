-- local get_windows = function()
-- 	local wins = vim.api.nvim_tabpage_list_wins(0)

-- 	for i, win in pairs(wins) do
-- 		local winnr = vim.api.nvim_win_get_number(win)
-- 		local buf = vim.api.nvim_win_get_buf(win)
-- 		local bufname = vim.api.nvim_buf_get_name(buf)
-- 		-- print("i=" .. tostring(i) .. ", winid=" .. tostring(winid) .. ", bufn=" .. tostring(bufnr) .. ", bufname=" .. bufname)
-- 		print(string.format("win=%d, winnr=%d, buf=%d, bufname=%s", win, winnr, buf, bufname))
-- 	end
-- end

-- local print_bufs = function(bufs)
-- 	for i, buf in pairs(bufs) do
-- 		-- local bufnr = vim.api.nvim_buf_get_number(buf)
-- 		local bufname = vim.api.nvim_buf_get_name(buf)
-- 		print(string.format("buf=%d, bufname=%s", buf, bufname))
-- 	end
-- end

-- local get_bufs = function()
-- 	local bufs = vim.api.nvim_list_bufs()
-- 	print_bufs(bufs)
-- end

-- local get_listed_bufs = function()
-- 	local bufs = vim.tbl_filter(function(b)
-- 		if 1 ~= vim.fn.buflisted(b) then
-- 			return false
-- 		end
-- 		return true
-- 	end, vim.api.nvim_list_bufs())
-- 	print_bufs(bufs)
-- end

-- local get_tabpages = function()
-- 	local tabs = vim.api.nvim_list_tabpages()
-- 	for i, tab in pairs(tabs) do
-- 		local tabnr = vim.api.nvim_tabpage_get_number(tab)
-- 		print(string.format("tab=%d, tabnr=%d", tab, tabnr))
-- 	end
-- end

-- -- get_windows()
-- -- get_bufs()
-- -- get_listed_bufs()
-- get_tabpages()
--

------------------------------
-- highlight library
------------------------------

local highlight = {}
---@param hls table
---@return nil
function highlight.set(hls)
	for group, value in pairs(hls) do
		vim.api.nvim_set_hl(0, group, value)
	end
end

---@param links table
---@return nil
function highlight.link(links)
	for from, to in pairs(links) do
		vim.api.nvim_set_hl(0, from, {
			link = to,
		})
	end
end

------------------------------
-- highlight settings
------------------------------

highlight.link { TabLineSel = 'Normal' }
highlight.set {
	TabLine = { fg = '#707070', bg = '#202020' },
	TabLineFill = { fg = 'NONE', bg = '#000000' },
}

------------------------------
-- core logic
------------------------------

local M = {}

---@return string
function Tabline()
	local s = ''
	for i = 1, vim.fn.tabpagenr('$') do
		local current = i == vim.fn.tabpagenr()
		local hl = current and '%#TabLineSel#' or '%#TabLine#'
		local id = '%' .. tostring(i) .. 'T'
		local label = (function()
			local buflist = vim.fn.tabpagebuflist(i)
			local winnr = vim.fn.tabpagewinnr(i)
			local name = vim.fn.bufname(buflist[winnr])
			local count = ''
			if not current then
				count = #buflist == 1 and '' or ' (' .. #buflist .. ')'
			end
			return ' ' .. vim.fn.fnamemodify(name, ':t') .. count .. ' '
		end)()
		s = s .. hl .. id .. label
	end
	return s .. '%#TabLineFill#%T'
end

vim.api.nvim_set_option_value(
	'tabline',
	'%!v:lua.Tabline()',
	{ scope = 'global' }
)

return M
