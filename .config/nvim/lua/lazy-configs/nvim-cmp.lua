local export = { 'hrsh7th/nvim-cmp' }

export.lazy = true

export.event = { "InsertEnter", "CmdlineEnter" }

export.dependencies = {
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-cmdline',
	"hrsh7th/cmp-nvim-lsp",
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
		dependencies = {
			{
				"zbirenbaum/copilot.lua",
				config = function()
					require("copilot").setup({
						suggestion = { enabled = false },
						panel = { enabled = false },
					})
				end
			},
		}
	},
	{
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
	},
	'saadparwaiz1/cmp_luasnip',
}

local has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

export.config = function()
	local cmp = require("cmp")

	cmp.setup {
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		snippet = {
			expand = function(args)
				require('luasnip').lsp_expand(args.body)
			end,
		},
		sources = {
			{
				name = "buffer",
				option = {
					-- Avoid dealing with huge buffers
					get_bufnrs = function()
						local buf = vim.api.nvim_get_current_buf()
						local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
						if byte_size > 1024 * 1024 then -- 1 Megabyte max
							return {}
						end
						return { buf }
					end
				},
			},
			{ name = "path", },
			-- { name = "copilot", group_index = 2 },
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
		},
		mapping = {
			-- CAUTION: cmp.foo is NOT equals to cmp.mapping.foo
			['<CR>'] = {
				i = function(fallback)
					if cmp.visible() then
						if (cmp.get_active_entry() == nil) then
							cmp.abort()
						else
							cmp.confirm({
								behavior = cmp.ConfirmBehavior.Replace,
								select = false,
							})
						end
					else
						fallback()
					end
				end,
			},
			['<C-n>'] = {
				i = cmp.mapping.select_next_item(),
			},
			['<Down>'] = {
				i = cmp.mapping.select_next_item(),
			},
			['<Tab>'] = {
				i = cmp.mapping.select_next_item(),
			},
			['<C-p>'] = {
				i = cmp.mapping.select_prev_item(),
			},
			['<Up>'] = {
				i = cmp.mapping.select_prev_item(),
			},
			['<S-Tab>'] = {
				i = cmp.mapping.select_prev_item(),
			},
		},
	}

	cmp.setup.cmdline("/", {
		mapping = {
			['<C-n>'] = {
				c = function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end,
			},
			['<C-p>'] = {
				c = function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end,
			},
			['<Up>'] = {
				c = function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					else
						fallback()
					end
				end,
			},
			['<Down>'] = {
				c = function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					else
						fallback()
					end
				end,
			},
			['<TAB>'] = {
				c = function(fallback)
					if cmp.visible() then
						cmp.close()
					else
						cmp.complete()
					end
				end,
			},
		},
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
		mapping = {
			['<CR>'] = {
				c = function(fallback)
					if cmp.visible() then
						if (cmp.get_active_entry() == nil) then
							cmp.abort()
						else
							cmp.confirm({
								behavior = cmp.ConfirmBehavior.Replace,
								select = false,
							})
						end
					else
						fallback()
					end
				end,
			},
			['<Tab>'] = {
				c = function()
					if require('cmp').visible() then
						require('cmp').select_next_item()
					else
						require('cmp').complete()
					end
				end,
			},
			-- ['<S-Tab>'] = {
			-- 	c = function()
			-- 		if require('cmp').visible() then
			-- 			require('cmp').select_prev_item()
			-- 		else
			-- 			require('cmp').complete()
			-- 		end
			-- 	end,
			-- },
			['<S-Tab>'] = {
				c = function()
					if require('cmp').visible() then
						require('cmp').select_next_item()
					else
						require('cmp').complete()
					end
				end,
			},
			['<ESC>'] = {
				c = function(fallback)
					if require('cmp').visible() then
						require('cmp').abort()
					else
						fallback()
					end
				end,
			},
		},
		sources = cmp.config.sources({
			{ name = "path" },
		}, {
			{
				name = "cmdline",
				option = {
					ignoer_cmds = { "Man", "!" }
				},
			}
		}),
		completion = {
			autocomplete = false
		},
	})
end

return export
