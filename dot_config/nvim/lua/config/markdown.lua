-- =============================================================================
-- markdown.lua — markview.nvim
-- =============================================================================

-- Tell markview we handle blink integration manually
vim.g.markview_blink_loaded = true

require("markview").setup({
	preview = {
		modes = { "n", "no", "c" },
		hybrid_modes = {},
	},
})

-- <leader>um: lives in the toggle group (<leader>t is the test group)
vim.keymap.set("n", "<leader>um", "<cmd>Markview<cr>", { desc = "Toggle: markdown preview" })
