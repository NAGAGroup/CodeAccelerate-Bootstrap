-- =============================================================================
-- lsp.lua — LSP setup: mason, mason-lspconfig, lazydev, LspAttach keymaps
-- =============================================================================
-- nvim-lspconfig on runtimepath → lsp/*.lua defaults auto-loaded by vim.lsp.config
-- mason-lspconfig automatic_enable → calls vim.lsp.enable() on install
-- Our lsp/clangd.lua and lsp/lua_ls.lua overrides merge with lspconfig defaults
-- No require('lspconfig') — deprecated framework module
-- =============================================================================

-- lazydev (MUST be before LSP enabling)
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
	integrations = { lspconfig = true, cmp = true },
})

-- mason
require("mason").setup({
	ui = {
		border = "rounded",
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- mason-lspconfig — automatic_enable calls vim.lsp.enable() on install
-- This is the FULL auto-setup for LSP: install → enable → FileType autocmd → attach
require("mason-lspconfig").setup({
	automatic_enable = true,
})

-- Global blink.cmp capabilities
local ok, blink = pcall(require, "blink.cmp")
if ok then
	vim.lsp.config("*", {
		capabilities = blink.get_lsp_capabilities(),
	})
end

-- LspAttach keymaps (LazyVim-style vocabulary)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", { clear = true }),
	callback = function(ev)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end
		-- Navigation
		map("n", "gd", vim.lsp.buf.definition, "LSP: goto definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP: goto declaration")
		map("n", "gI", vim.lsp.buf.implementation, "LSP: goto implementation")
		map("n", "gy", vim.lsp.buf.type_definition, "LSP: goto type definition")
		map("n", "gr", vim.lsp.buf.references, "LSP: references")
		-- Documentation
		map("n", "K", vim.lsp.buf.hover, "LSP: hover")
		map("n", "gK", vim.lsp.buf.signature_help, "LSP: signature help")
		map("i", "<C-k>", vim.lsp.buf.signature_help, "LSP: signature help")
		-- Actions
		map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")
		map("v", "<leader>ca", vim.lsp.buf.code_action, "LSP: code action (visual)")
		map("n", "<leader>cr", vim.lsp.buf.rename, "LSP: rename")
		map("n", "<leader>cf", function()
			require("conform").format({ async = true, lsp_format = "fallback" })
		end, "Format")
		map("n", "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "LSP: definitions/references")
	end,
})
