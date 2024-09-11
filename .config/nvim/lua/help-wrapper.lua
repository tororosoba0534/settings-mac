local export = {}

--- :help command wrapper.
--- If there is only one window, then open vertically split help window.
--- Else open help page in the current window.
--- @param term string
export.open_help = function(term)
	if #vim.api.nvim_list_wins() == 1 then
		vim.cmd('vert help ' .. term)
	end

	local tmp = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_set_current_buf(tmp)
	vim.api.nvim_set_option_value('buftype', 'help', { buf = tmp })
	vim.cmd('help ' .. term)
	-- TODO: garbage-collect tmp buffers
end

return export
