-- =============================================================================
-- lsp/yamlls.lua — YAML LSP override: SchemaStore schemas
-- =============================================================================
-- Merges with lspconfig's default yamlls config.
-- yamlls' built-in schemaStore support is disabled in favor of the
-- SchemaStore.nvim plugin (more complete, locally cached catalog).
-- =============================================================================

return {
	settings = {
		yaml = {
			schemaStore = {
				-- Disable built-in support; use SchemaStore.nvim instead.
				enable = false,
				url = "", -- avoids a nil-check error in yamlls when disabled
			},
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}
