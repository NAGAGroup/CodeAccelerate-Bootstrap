-- =============================================================================
-- toggles.lua — Feature toggle system (<leader>u*) via Snacks.toggle
-- =============================================================================
-- Snacks.toggle gives stateful toggles with which-key integration (shows
-- current state in the popup). Loaded after ui.lua (snacks.setup done).
-- =============================================================================

-- Format on save (global) — vim.g.autoformat: nil/true = enabled, false = disabled
Snacks.toggle({
	name = "Format on Save (global)",
	get = function()
		return vim.g.autoformat ~= false
	end,
	set = function(state)
		vim.g.autoformat = state
	end,
}):map("<leader>uf")

-- Format on save (buffer) — nil inherits the global setting
Snacks.toggle({
	name = "Format on Save (buffer)",
	get = function()
		local b = vim.b.autoformat
		if b == nil then
			return vim.g.autoformat ~= false
		end
		return b
	end,
	set = function(state)
		vim.b.autoformat = state
	end,
}):map("<leader>uF")

-- Linting
vim.g.lint_disabled = false
Snacks.toggle({
	name = "Linting",
	get = function()
		return not vim.g.lint_disabled
	end,
	set = function(state)
		vim.g.lint_disabled = not state
		if state then
			require("lint").try_lint()
		end
	end,
}):map("<leader>ul")

-- Diagnostics / inlay hints / UI options (snacks built-ins)
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.inlay_hints():map("<leader>uh")
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Numbers" }):map("<leader>uL")
Snacks.toggle.indent():map("<leader>ug")
Snacks.toggle.dim():map("<leader>uD")

-- Git signs
Snacks.toggle({
	name = "Git Signs",
	get = function()
		return require("gitsigns.config").config.signcolumn
	end,
	set = function(state)
		require("gitsigns").toggle_signs(state)
	end,
}):map("<leader>uG")
