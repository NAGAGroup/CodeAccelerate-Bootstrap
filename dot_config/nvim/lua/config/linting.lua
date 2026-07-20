-- =============================================================================
-- linting.lua — nvim-lint registration + lint triggers
-- =============================================================================
-- linters_by_ft is the comprehensive curated table owned by auto-setup.lua.
-- Only linters whose executable is actually available are run — this avoids
-- "executable not found" noise while auto-setup is still installing a tool
-- on first filetype open.
-- =============================================================================

local lint = require("lint")
lint.linters_by_ft = require("config.auto-setup").linters_by_ft

local function lint_buffer()
	if vim.g.lint_disabled then
		return
	end
	local names = lint.linters_by_ft[vim.bo.filetype]
	if not names then
		return
	end
	-- Filter to linters whose executable exists (mason may still be installing)
	local runnable = {}
	for _, name in ipairs(names) do
		local linter = lint.linters[name]
		if linter then
			if type(linter) == "function" then
				linter = linter()
			end
			local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
			if cmd and vim.fn.executable(cmd) == 1 then
				table.insert(runnable, name)
			end
		end
	end
	if #runnable > 0 then
		lint.try_lint(runnable)
	end
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
	callback = function()
		vim.schedule(lint_buffer)
	end,
	desc = "Run nvim-lint on buffer events",
})
