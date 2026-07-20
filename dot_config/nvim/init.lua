-- =============================================================================
-- Neovim v0.12 Config — vim.pack (built-in plugin manager)
-- =============================================================================
-- Architecture base: LazyVim v16 patterns, implemented from scratch.
-- Plugin manager: vim.pack (NOT lazy.nvim — hard requirement).
-- LSP: native vim.lsp.config/enable + lspconfig lsp/ defaults + selective overrides.
-- Auto-setup: LSP/formatter/linter/DAP auto-install on filetype open.
-- =============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local gh = function(r)
	return "https://github.com/" .. r
end

-- =============================================================================
-- Plugin declarations — vim.pack.add() is idempotent (no-op if already installed)
-- =============================================================================
do
	vim.pack.add({
		-- Core / Spine
		gh("folke/snacks.nvim"),
		gh("nvim-mini/mini.nvim"), -- pairs, surround, ai, move, files, snippets, icons

		-- LSP / Mason
		gh("neovim/nvim-lspconfig"),
		gh("mason-org/mason.nvim"),
		gh("mason-org/mason-lspconfig.nvim"),
		gh("folke/lazydev.nvim"),

		-- Completion + Snippets
		{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
		gh("rafamadriz/friendly-snippets"),

		-- Treesitter
		{ src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },

		-- Formatting / Linting
		gh("stevearc/conform.nvim"),
		gh("mfussenegger/nvim-lint"),

		-- Navigation
		gh("folke/flash.nvim"),
		gh("folke/persistence.nvim"),
		gh("MagicDuck/grug-far.nvim"),

		-- Editing QoL
		gh("folke/ts-comments.nvim"),
		gh("folke/todo-comments.nvim"),
		gh("ThePrimeagen/refactoring.nvim"),
		gh("monaqa/dial.nvim"),

		-- Git
		gh("lewis6991/gitsigns.nvim"),

		-- DAP / Debugging
		gh("mfussenegger/nvim-dap"),
		{ src = gh("igorlfs/nvim-dap-view"), version = vim.version.range("1.*") },
		gh("jay-babu/mason-nvim-dap.nvim"),

		-- Build / Test
		gh("Civitasv/cmake-tools.nvim"),
		gh("nvim-neotest/neotest"),
		gh("alfaix/neotest-gtest"),
		gh("nvim-neotest/nvim-nio"),

		-- C++ specific
		gh("dchinmay2/clangd_extensions.nvim"),

		-- UI
		gh("nvim-lualine/lualine.nvim"),
		gh("folke/which-key.nvim"),
		gh("folke/trouble.nvim"),
		gh("Shatur/neovim-ayu"),
		gh("Amansingh-afk/milli.nvim"),

		-- Markdown
		gh("OXY2DEV/markview.nvim"),
		gh("b0o/SchemaStore.nvim"),

		-- Utilities
		gh("nvim-lua/plenary.nvim"),
		gh("lewis6991/async.nvim"), -- refactoring.nvim dependency (module "async")
	}, { confirm = false }) -- frictionless bootstrap: no per-plugin confirm prompt
end

-- =============================================================================
-- Module load order
-- =============================================================================
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.treesitter")
require("config.diagnostics")
require("config.lsp")
require("config.formatting")
require("config.linting")
require("config.auto-setup").setup() -- CRITICAL: .setup() creates the auto-install autocmd
require("config.dap")
require("config.completion")
require("config.ui")
require("config.navigation")
require("config.editing")
require("config.git")
require("config.testing")
require("config.cmake")
require("config.markdown")
require("config.toggles")
require("config.builtins")

-- Colorscheme — applied LAST after all plugins are configured
pcall(vim.cmd.colorscheme, "ayu-dark")
