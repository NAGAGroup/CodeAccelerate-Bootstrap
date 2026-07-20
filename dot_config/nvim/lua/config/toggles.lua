-- =============================================================================
-- toggles.lua — Feature toggle system (<leader>u*)
-- =============================================================================

-- Format on save (global) — vim.g.autoformat convention
vim.keymap.set("n", "<leader>uf", function()
	vim.g.autoformat = not vim.g.autoformat
	vim.notify("Format on save: " .. (vim.g.autoformat and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: format on save (global)" })

-- Format on save (buffer)
vim.keymap.set("n", "<leader>uF", function()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].autoformat = not vim.b[bufnr].autoformat
	vim.notify("Format on save (buffer): " .. (vim.b[bufnr].autoformat and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: format on save (buffer)" })

-- Linting
vim.g.lint_disabled = false
vim.keymap.set("n", "<leader>ul", function()
	vim.g.lint_disabled = not vim.g.lint_disabled
	vim.notify("Linting: " .. (not vim.g.lint_disabled and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: linting" })

-- Diagnostics
vim.keymap.set("n", "<leader>ud", function()
	local cfg = vim.diagnostic.config()
	local enabled = cfg and cfg.virtual_text ~= false
	vim.diagnostic.config({
		virtual_text = not enabled,
		signs = not enabled,
		underline = not enabled,
	})
	vim.notify("Diagnostics: " .. (not enabled and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: diagnostics" })

-- Inlay hints
vim.keymap.set("n", "<leader>uh", function()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
	vim.notify("Inlay hints: " .. (not enabled and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: inlay hints" })

-- Spell
vim.keymap.set("n", "<leader>us", function()
	vim.opt_local.spell = not vim.opt_local.spell:get()
	vim.notify("Spell: " .. (vim.opt_local.spell:get() and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: spell" })

-- Wrap
vim.keymap.set("n", "<leader>uw", function()
	vim.opt_local.wrap = not vim.opt_local.wrap:get()
	vim.notify("Wrap: " .. (vim.opt_local.wrap:get() and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: wrap" })

-- Relative numbers
vim.keymap.set("n", "<leader>uL", function()
	vim.opt.relativenumber = not vim.opt.relativenumber:get()
	vim.notify("Relative numbers: " .. (vim.opt.relativenumber:get() and "ENABLED" or "DISABLED"))
end, { desc = "Toggle: relative numbers" })

-- Indent guides (snacks.indent)
vim.keymap.set("n", "<leader>ug", function()
	Snacks.toggle.indent()()
end, { desc = "Toggle: indent guides" })

-- Git signs
vim.keymap.set("n", "<leader>uG", function()
	Snacks.toggle.git()()
end, { desc = "Toggle: git signs" })
