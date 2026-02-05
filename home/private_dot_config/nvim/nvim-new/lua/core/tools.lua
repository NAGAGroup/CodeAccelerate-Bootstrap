-- Tool installer via mason-tool-installer

local add = MiniDeps.add
add("WhoIsSethDaniel/mason-tool-installer.nvim")

require("mason-tool-installer").setup({
	ensure_installed = {
		-- Formatters
		"clang-format",
		"ruff",
		"biome",
		"shfmt",
		"prettier",
		"taplo",
		"mdformat",
		"stylua",

		-- Linters
		"shellcheck",

		-- Debuggers
		"codelldb",

		-- Language servers (installed via Mason)
		"clangd",
		"basedpyright",
		"vtsls",
		"bash-language-server",
		"json-lsp",
		"yaml-language-server",
		"taplo",
		"marksman",
		"lua-language-server",
	},
	auto_update = false,
	run_on_start = true,
})
