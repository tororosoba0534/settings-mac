local export = { 'hrsh7th/nvim-cmp' }

local cmp = require("cmp")

export.lazy = true

export.event = { "InsertEnter" }

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
	cmp.setup.global({
		snippet = {
			expand = function(args)
				require('luasnip').lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		mapping = {
			['<CR>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				selec = true,
			}),
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<Up>'] = cmp.mapping.select_prev_item(),
			['<Down>'] = cmp.mapping.select_next_item(),
			['<Tab>'] = vim.schedule_wrap(function(fallback)
				if cmp.visible() and has_words_before() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					fallback()
				end
			end),
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
	})

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
