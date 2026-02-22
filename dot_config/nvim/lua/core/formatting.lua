-- Formatting via conform.nvim

local add = MiniDeps.add
add("stevearc/conform.nvim")

require("conform").setup({
	formatters_by_ft = {
		-- C/C++
		c = { "clang_format" },
		cpp = { "clang_format" },

		-- Python
		python = { "ruff_format" },

		-- JavaScript/TypeScript
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome" },
		typescriptreact = { "biome" },

		-- Shell
		bash = { "shfmt" },
		sh = { "shfmt" },

		-- Config formats
		json = { "biome" },
		yaml = { "prettier" },
		toml = { "taplo" },

		-- Markdown
		-- markdown = { 'mdformat' },

		-- Lua
		lua = { "stylua" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
})

-- Format keymap
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format buffer" })
