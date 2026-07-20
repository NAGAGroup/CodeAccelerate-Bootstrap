-- =============================================================================
-- linting.lua — nvim-lint lint triggers
-- =============================================================================
-- lint.linters_by_ft is set in auto-setup.lua
-- (which owns the comprehensive filetype→linter table).
-- This module just sets up the lint trigger autocmd.
-- =============================================================================

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
	callback = function()
		if vim.g.lint_disabled then
			return
		end
		vim.schedule(function()
			require("lint").try_lint()
		end)
	end,
	desc = "Run nvim-lint on buffer events",
})
