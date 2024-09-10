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
					if cmp.get_selected_entry() == nil then
						fallback()
						-- elseif luasnip.expandable() then
						-- 	luasnip.expand()
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
					if (cmp.get_selected_entry() == nil) then
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
		['<C-n>'] = {
			i = function()
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end,
		},
		['<Down>'] = {
			i = function()
				if cmp.visible() then
					cmp.select_next_item()
				else
					cmp.complete()
				end
			end,
		},
		['<Tab>'] = {
			i = function()
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.locally_jumpable(1) then
					luasnip.jump(1)
				else
					cmp.complete()
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
			i = function()
				if cmp.visible() then
					cmp.select_prev_item()
				else
					cmp.complete()
				end
			end,
		},
		['<Up>'] = {
			i = function()
				if cmp.visible() then
					cmp.select_prev_item()
				else
					cmp.complete()
				end
			end,
		},
		['<S-Tab>'] = {
			i = function()
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				else
					cmp.complete()
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
		['<C-e>'] = {
			i = function()
				if cmp.visible_docs() then
					cmp.close_docs()
				elseif cmp.visible() then
					cmp.close()
				else
					cmp.complete()
				end
			end,
			c = function()
				if cmp.visible() then
					cmp.abort()
				else
					cmp.complete()
				end
			end,
		},
		['<ESC>'] = {
			i = function(fallback)
				if cmp.visible() then
					if cmp.get_selected_entry() == nil then
						fallback()
					else
						cmp.abort()
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

-- -- If you want to merge some bindings, setup like this:
-- local mapping_cmd_search = function(cmp, cmp_utils_misc)
-- 	return cmp_utils_misc.merge(
-- 		{
-- 			['<CR>'] = {
-- 				c = function(fallback)
-- 				        -- Do something
-- 					end
-- 				end,
-- 			},
-- 		},
-- 		mapping(cmp)
-- 	)
-- end


export.config = function()
	local cmp = require("cmp")

	cmp.setup {
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		preselect = cmp.PreselectMode.None,
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
