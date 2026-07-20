-- =============================================================================
-- lsp/jsonls.lua — JSON LSP override: SchemaStore schemas + validation
-- =============================================================================
-- Merges with lspconfig's default jsonls config.
-- =============================================================================

return {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
}
