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
		'saadparwaiz1/cmp_luasnip',
		dependencies = {
			'L3MON4D3/LuaSnip',
		},
	},
}

local mapping = function(cmp)
	local luasnip = require("luasnip")
	return {
		-- CAUTION: cmp.foo is NOT equals to cmp.mapping.foo
		['<CR>'] = {
			i = function(fallback)
				if cmp.visible() then
					if (cmp.get_active_entry() == nil) then
						fallback()
					elseif luasnip.expandable() then
						luasnip.expand()
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
		['<C-n>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end,
		},
		['<Down>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end,
		},
		['<Tab>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				else
					fallback()
				end
			end,
			c = function()
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end,
		},
		['<C-p>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end,
		},
		['<Up>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end,
		},
		['<S-Tab>'] = {
			i = function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end,
			c = function()
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end,
		},
		['<ESC>'] = {
			i = function(fallback)
				if cmp.visible() then
					if (cmp.get_active_entry() == nil) then
						fallback()
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
			c = function()
				if cmp.visible() then
					cmp.abort()
				else
					-- Send <C-c>
					local key = vim.api.nvim_replace_termcodes('<C-c>', true, false, true)
					vim.api.nvim_feedkeys(key, 'm', false)
				end
			end,
		},
	}
end

local mapping_cmd_search = function(cmp, cmp_utils_misc)
	return cmp_utils_misc.merge(
		{
			['<CR>'] = {
				c = function(fallback)
					if cmp.visible() then
						if (cmp.get_active_entry() == nil) then
							fallback()
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
		},
		mapping(cmp)
	)
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
			{ name = 'luasnip',  group_index = 1, },
			{ name = "copilot",  group_index = 1 },
			{ name = 'nvim_lsp', group_index = 1, },
			{ name = "path",     group_index = 3, },
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
				group_index = 3,
			},
		},
		mapping = mapping(cmp),
	}

	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
		mapping = mapping_cmd_search(cmp, require('cmp.utils.misc')),
	})

	cmp.setup.cmdline(":", {
		sources = {
			{ name = "path" },
			{
				name = "cmdline",
				option = {
					ignoer_cmds = { "Man", "!" }
				},
			}
		},
		completion = {
			autocomplete = false
		},
	})
end

return export
