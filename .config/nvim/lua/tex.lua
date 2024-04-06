local function compile()
	if (vim.bo.filetype == "tex") then
		-- vim.system({ 'latexmk', '-cd', '%:h/ %' })
		vim.system({ 'echo', 'HELLO WORLD' })
	end
end
vim.api.nvim_create_user_command("Tex", compile, {})
