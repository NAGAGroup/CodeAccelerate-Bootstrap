-- =============================================================================
-- formatting.lua — conform.nvim setup + format-on-save + format keymap
-- =============================================================================
-- formatters_by_ft is the comprehensive curated table owned by auto-setup.lua.
-- lsp_format = "fallback": filetypes without a curated formatter use the LSP
-- server's formatting (this is what covers uncurated filetypes automatically).
-- =============================================================================

require("conform").setup({
	formatters_by_ft = require("config.auto-setup").formatters_by_ft,
	format_on_save = function(bufnr)
		-- vim.g.autoformat / vim.b.autoformat: nil or true = enabled, false = disabled
		if vim.g.autoformat == false or vim.b[bufnr].autoformat == false then
			return nil
		end
		return { timeout_ms = 3000, lsp_format = "fallback" }
	end,
})

-- Hook gq into conform
vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"

-- Manual format keymap
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format" })
