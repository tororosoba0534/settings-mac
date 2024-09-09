local export = { "L3MON4D3/LuaSnip" }

export.config = function()
	require('luasnip.loaders.from_lua').load()
end

return export
