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

local mapping = function(cmp)
	return {
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
			i = cmp.mapping.select_next_item(),
		},
		['<Down>'] = {
			i = cmp.mapping.select_next_item(),
		},
		['<Tab>'] = {
			i = cmp.mapping.select_next_item(),
			c = function()
				if require('cmp').visible() then
					require('cmp').select_next_item()
				else
					require('cmp').complete()
				end
			end,
		},
		['<C-p>'] = {
			i = cmp.mapping.select_prev_item(),
		},
		['<Up>'] = {
			i = cmp.mapping.select_prev_item(),
		},
		['<S-Tab>'] = {
			i = cmp.mapping.select_prev_item(),
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
	}
end

-- https://github.com/hrsh7th/nvim-cmp/discussions/1834
local kind_priority = {
	Parameter = 100,
	Variable = 95,
	Field = 90,
	Property = 85,
	Constant = 80,
	Enum = 75,
	EnumMember = 70,
	Event = 65,
	Function = 60,
	Method = 55,
	Operator = 50,
	Reference = 45,
	Struct = 40,
	File = 35,
	Folder = 30,
	Class = 27,
	Color = 25,
	Module = 20,
	Keyword = 16,
	Constructor = 13,
	Interface = 10,
	Snippet = 7,
	TypeParameter = 5,
	Unit = 3,
	Value = 1,
	Text = 0,
}

local kind_priority_comparator = function(cmp_types_lsp)
	local lsp = cmp_types_lsp
	return function(entry1, entry2)
		if entry1.source.name ~= "nvim_lsp" then
			if entry2.source.name == "nvim_lsp" then
				return false
			else
				return nil
			end
		end
		local kind1 = lsp.CompletionItemKind[entry1:get_kind()]
		local kind2 = lsp.CompletionItemKind[entry2:get_kind()]
		-- if kind1 == "Variable" and entry1:get_completion_item().label:match("%w*=") then
		-- 	kind1 = "Parameter"
		-- end
		-- if kind2 == "Variable" and entry2:get_completion_item().label:match("%w*=") then
		-- 	kind2 = "Parameter"
		-- end

		local priority1 = kind_priority[kind1] or 0
		local priority2 = kind_priority[kind2] or 0
		if priority1 == priority2 then
			return nil
		end
		return priority1 < priority2
	end
end

local label_comparator = function(entry1, entry2)
	return entry1.completion_item.label > entry2.completion_item.label
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
			{ name = 'nvim_lsp', group_index = 5, },
			{ name = "path",     group_index = 10, },
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
				group_index = 20,
			},
			-- { name = "copilot", group_index = 2 },
		},
		mapping = mapping(cmp),
		comparators = {
			kind_priority_comparator(require('cmp.types.lsp')),
			label_comparator,
		}
	}

	cmp.setup.cmdline("/", {
		sources = {
			{ name = "buffer" },
		},
	})

	cmp.setup.cmdline(":", {
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
