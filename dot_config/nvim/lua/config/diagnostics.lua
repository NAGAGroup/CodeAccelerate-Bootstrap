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

-- Navigation (0.12 API: vim.diagnostic.jump)
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump.prev()
end, { desc = "Diagnostic: prev" })
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump.next()
end, { desc = "Diagnostic: next" })
vim.keymap.set("n", "[e", function()
	vim.diagnostic.jump.prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Diagnostic: prev error" })
vim.keymap.set("n", "]e", function()
	vim.diagnostic.jump.next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Diagnostic: next error" })
vim.keymap.set("n", "[w", function()
	vim.diagnostic.jump.prev({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Diagnostic: prev warning" })
vim.keymap.set("n", "]w", function()
	vim.diagnostic.jump.next({ severity = vim.diagnostic.severity.WARN })
end, { desc = "Diagnostic: next warning" })
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnostic: line float" })
