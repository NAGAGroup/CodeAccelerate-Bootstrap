-- =============================================================================
-- formatting.lua — conform.nvim format keymap + lint trigger
-- =============================================================================
-- conform.setup() with formatters_by_ft is called in auto-setup.lua
-- (which owns the comprehensive filetype→formatter table).
-- This module just adds the manual format keymap.
-- =============================================================================

-- Manual format keymap
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
