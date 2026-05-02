-- Section 1: lazydev.nvim setup (MUST be before LSP enabling)
-- lazydev must be setup before lua_ls is enabled
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
	integrations = {
		lspconfig = true,
		cmp = true, -- registers as blink.cmp source automatically
	},
})

-- Section 2: mason.nvim setup
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

-- Section 3: mason-tool-installer setup
require("mason-tool-installer").setup({
	ensure_installed = {
		-- LSP servers (Mason package names)
		"clangd",
		"basedpyright",
		"vtsls",
		"bashls",
		"jsonls",
		"yamlls",
		"lua_ls",
		"taplo",
		"marksman",

		-- Formatters
		"clang-format",
		"ruff",
		"biome",
		"shfmt",
		"prettier",
		"stylua",
		"mdformat",

		-- Linters
		"shellcheck",
	},
})

-- Section 4: mason-lspconfig setup
require("mason-lspconfig").setup({
	automatic_enable = true, -- calls vim.lsp.enable() automatically for installed servers
})

-- Section 5: Global blink.cmp capabilities (explicit, belt-and-suspenders)
-- Ensure blink.cmp capabilities are registered globally
-- blink.cmp auto-registers at startup, but this is explicit for safety
local ok, blink = pcall(require, "blink.cmp")
if ok then
	vim.lsp.config("*", {
		capabilities = blink.get_lsp_capabilities(),
	})
end

-- Section 6: LspAttach autocmd (keymaps + progress)
local lsp_augroup = vim.api.nvim_create_augroup("my.lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lsp_augroup,
	callback = function(ev)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		-- Navigation
		map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
		map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to implementation")
		map("n", "gr", vim.lsp.buf.references, "LSP: Go to references")
		-- Documentation
		map("n", "K", vim.lsp.buf.hover, "LSP: Hover documentation")
		map("n", "<C-k>", vim.lsp.buf.signature_help, "LSP: Signature help")
		-- Actions
		map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
		map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action")
		map("v", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code action (visual)")
	end,
})
