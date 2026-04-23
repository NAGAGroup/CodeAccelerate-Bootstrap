-- =============================================================================
-- Neovim v0.12 Config Rebuild
-- =============================================================================
-- Package manager : vim.pack (built-in, v0.12+)
-- Lockfile        : nvim-pack-lock.json
-- Structure       : init.lua -> lua/config/*.lua + lsp/*.lua
--
-- Module load order:
--   1.  options       -- vim.opt settings, OSC52 clipboard, folding
--   2.  keymaps       -- core keymaps (no plugin keymaps here)
--   3.  autocmds      -- augroups: yank, q-close, checktime, resize,
--                        trim-whitespace, wrap/spell, dapui, treesitter-folds
--   4.  lsp           -- mason, mason-lspconfig, LspAttach keymaps, LspProgress
--   5.  diagnostics   -- vim.diagnostic config, CursorHold float
--   6.  toggles       -- format/lint/diag/inlay/spell/wrap/number toggles
--   7.  formatting    -- conform.nvim with gated format-on-save
--   8.  linting       -- nvim-lint with lint_disabled gate
--   9.  completion    -- blink.cmp + LuaSnip + blink-copilot
--   10. ui            -- ayu, snacks, alpha, lualine, bufferline, which-key, trouble
--   11. navigation    -- snacks.picker, mini.files, harpoon2
--   12. editing       -- mini.*, flash, refactoring, todo-comments, persistence
--   13. git           -- gitsigns with nav_hunk
--   14. treesitter    -- native v0.12 TS + tree-sitter-manager.nvim
--   15. dap           -- nvim-dap + dap-ui, codelldb + debugpy
--   16. cmake         -- cmake-tools.nvim (CMakePresets workflow)
--   17. testing       -- SKIPPED (neotest phase deferred)
--   18. markdown      -- markview.nvim, lazydev.nvim, SchemaStore.nvim
--   19. builtins      -- undotree, difftool, UI2 (experimental)
--
-- LSP servers (lsp/*.lua): clangd, basedpyright, vtsls, lua_ls, jsonls,
--   yamlls, bashls, cmake, taplo, marksman, nushell
--
-- Key decisions:
--   * nvim-treesitter ARCHIVED Apr 3 2026 -> native v0.12 treesitter
--   * Textobject keymaps af/if/ac/ic/]m/[m -> native an/in/]n/[n
--   * FixCursorHold.nvim removed (CursorHold fixed in v0.12)
--   * copilot.lua/CopilotChat skipped (blink-copilot handles completion)
--   * UI2 enabled experimentally (suppress Press ENTER prompts)
-- =============================================================================

-- =============================================================================
-- new_config/init.lua — Neovim v0.12 Configuration
-- =============================================================================
-- Plugin manager : vim.pack (built-in, Neovim v0.12+)
-- Structure      : lua/config/ for modules | lsp/ for per-server LSP definitions
-- Load order     : leader globals → vim.pack.add() → require modules → colorscheme
--
-- Modules loaded (in order):
--   config.options      — vim.opt / vim.g settings
--   config.keymaps      — non-plugin keymaps
--   config.autocmds     — autocommand groups
--   config.lsp          — LSP server enabling + LspAttach keymaps
--   config.diagnostics  — diagnostic display + navigation
--   config.toggles      — feature toggle system (format/lint/diag/etc.)
--   config.formatting   — conform.nvim (format on save)
--   config.linting      — nvim-lint (async linting)
--   config.completion   — blink.cmp + LuaSnip + blink-copilot
--   config.ui           — colorscheme, lualine, bufferline, alpha, which-key, trouble, snacks
--   config.navigation   — snacks picker, mini.files, harpoon, root detection
--   config.editing      — mini.*, flash, refactoring, todo-comments, persistence
--   config.git          — gitsigns
--   config.treesitter   — native v0.12 treesitter + parser management
--   config.dap          — nvim-dap adapters + dap-ui
--   config.cmake        — cmake-tools.nvim
--   config.testing      — neotest + catch2 adapter + neotest-ctest
--   config.copilot      — copilot.lua + CopilotChat.nvim
--   config.markdown     — markview.nvim + lazydev.nvim
-- =============================================================================

-- Leader key — must be set before vim.pack.add() and all plugin loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Helper to shorten GitHub plugin declarations
local gh = function(r)
	return "https://github.com/" .. r
end

-- =============================================================================
-- Plugin declarations using vim.pack
-- =============================================================================
-- Plugin declarations — vim.pack.add() is idempotent (no-op if already installed)
do
	vim.pack.add({
		-- Core Infrastructure
		gh("folke/snacks.nvim"),
		gh("echasnovski/mini.nvim"),
		gh("neovim/nvim-lspconfig"),
		gh("williamboman/mason.nvim"),
		gh("williamboman/mason-lspconfig.nvim"),
		gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
		gh("nvim-lua/plenary.nvim"),

		-- Completion & Snippets
		{ src = gh("saghen/blink.cmp"), version = "v1" },
		gh("L3MON4D3/LuaSnip"),
		gh("rafamadriz/friendly-snippets"),

		-- UI
		gh("nvim-lualine/lualine.nvim"),
		gh("akinsho/bufferline.nvim"),
		gh("nvim-tree/nvim-web-devicons"),
		gh("goolord/alpha-nvim"),
		gh("Shatur/neovim-ayu"),
		gh("folke/which-key.nvim"),
		gh("folke/trouble.nvim"),

		-- Navigation
		gh("folke/flash.nvim"),
		{ src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
		gh("folke/persistence.nvim"),

		-- Editing
		gh("lewis6991/async.nvim"),
		gh("ThePrimeagen/refactoring.nvim"),
		gh("folke/todo-comments.nvim"),
		gh("JoosepAlviste/nvim-ts-context-commentstring"),

		-- Git
		gh("lewis6991/gitsigns.nvim"),

		-- Language Support
		gh("romus204/tree-sitter-manager.nvim"),
		gh("OXY2DEV/markview.nvim"),
		gh("folke/lazydev.nvim"),
		gh("b0o/SchemaStore.nvim"),

		-- DAP / Debugging
		gh("mfussenegger/nvim-dap"),
		gh("rcarriga/nvim-dap-ui"),
		gh("nvim-neotest/nvim-nio"),

		-- Build / Test
		gh("Civitasv/cmake-tools.nvim"),
		gh("nvim-neotest/neotest"),
		gh("orjangj/neotest-ctest"),

		-- Formatting / Linting
		gh("stevearc/conform.nvim"),
		gh("mfussenegger/nvim-lint"),
	})
end

-- =============================================================================
-- Load configuration modules (in order)
-- =============================================================================
local function safe_require(module)
	local ok, result = pcall(require, module)
	if not ok then
		-- Silently skip missing modules during verification
		return nil
	end
	return result
end

safe_require("config.options")
safe_require("config.keymaps")
safe_require("config.autocmds")
safe_require("config.lsp")
safe_require("config.diagnostics")
safe_require("config.toggles")
safe_require("config.formatting")
safe_require("config.linting")
safe_require("config.completion")
safe_require("config.ui")
safe_require("config.navigation")
safe_require("config.editing")
safe_require("config.git")
safe_require("config.treesitter")
safe_require("config.dap")
safe_require("config.cmake")
safe_require("config.testing")
safe_require("config.markdown")
safe_require("config.builtins")

-- =============================================================================
-- Colorscheme — applied last after all plugins are loaded
-- =============================================================================
pcall(vim.cmd.colorscheme, "ayu-dark")
