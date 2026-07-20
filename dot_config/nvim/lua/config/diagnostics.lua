-- =============================================================================
-- diagnostics.lua — Diagnostic display + navigation (0.12 API)
-- =============================================================================

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		source = "if_many",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	underline = true,
	severity_sort = true,
	float = {
		focus = false,
		scope = "cursor",
		border = "rounded",
	},
})

-- CursorHold float
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { scope = "cursor", focus = false })
	end,
	desc = "Show diagnostic float on cursor hold",
})

-- Navigation (0.12 API: vim.diagnostic.jump({ count = N, severity = S }))
local function diag_jump(count, severity)
	return function()
		vim.diagnostic.jump({ count = count * vim.v.count1, severity = severity })
	end
end
vim.keymap.set("n", "[d", diag_jump(-1), { desc = "Diagnostic: prev" })
vim.keymap.set("n", "]d", diag_jump(1), { desc = "Diagnostic: next" })
vim.keymap.set("n", "[e", diag_jump(-1, vim.diagnostic.severity.ERROR), { desc = "Diagnostic: prev error" })
vim.keymap.set("n", "]e", diag_jump(1, vim.diagnostic.severity.ERROR), { desc = "Diagnostic: next error" })
vim.keymap.set("n", "[w", diag_jump(-1, vim.diagnostic.severity.WARN), { desc = "Diagnostic: prev warning" })
vim.keymap.set("n", "]w", diag_jump(1, vim.diagnostic.severity.WARN), { desc = "Diagnostic: next warning" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic: line float" })
