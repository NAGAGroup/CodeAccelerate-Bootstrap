return {
	"neovim/nvim-lspconfig",
	opts = {
		setup = {
			clangd = function(_, opts)
				opts.capabilities.offsetEncoding = { "utf-16" }
				opts.cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--suggest-missing-includes",
					"--completion-style=detailed",
					"--header-insertion=iwyu",
					"--log=error",
					"--pretty",
					"--limit-results=100",
				}
			end,
			servers = {
				clangd = {
					mason = false,
				},
			},
		},
	},
}
