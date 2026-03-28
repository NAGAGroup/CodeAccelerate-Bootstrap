-- Language-specific plugins and configurations

local add = MiniDeps.add

-- This module is primarily for language-specific tooling beyond LSP/format/lint
-- Most language support is already configured in core/lsp.lua, core/formatting.lua, core/linting.lua

-- Lua development support (works with lua_ls to provide types for vim, vim.uv, etc.)
add("folke/lazydev.nvim")
require("lazydev").setup({
	library = {
		-- Load luvit types when the `vim.uv` word is found
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- JSON and YAML schema support via SchemaStore
add("b0o/SchemaStore.nvim")
-- No setup needed — it's a library plugin used by LSP configs

-- Additional language-specific configurations can be added here as needed
-- For now, the core language support is complete via the core modules
