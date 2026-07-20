-- =============================================================================
-- lsp/clangd.lua — C/C++ LSP override
-- =============================================================================
-- Merges with lspconfig's default clangd config (filetypes, root_markers, etc.)
-- We override cmd flags and capabilities for optimal C++ experience.
-- =============================================================================

return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--fallback-style=llvm",
	},
	capabilities = {
		offsetEncoding = { "utf-16" },
	},
	init_options = {
		usePlaceholders = true,
		completeUnimported = true,
		clangdFileStatus = true,
	},
}
