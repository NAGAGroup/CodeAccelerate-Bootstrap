-- =============================================================================
-- lsp/lua_ls.lua — Lua LSP override
-- =============================================================================
-- lazydev handles most library paths, but custom settings improve experience.
-- =============================================================================

return {
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			hint = { enable = true, paramType = true },
			workspace = { checkThirdParty = false },
		},
	},
}
