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

vim.keymap.set("n", "<leader>tm", "<cmd>Markview<cr>", { desc = "Toggle markdown preview" })
