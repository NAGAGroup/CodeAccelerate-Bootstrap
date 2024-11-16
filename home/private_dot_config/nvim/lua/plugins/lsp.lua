return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			-- Move the servers table directly under opts
			servers = {
				neocmake = {
					mason = false,
				},
				bashls = {
					cmd = { "bash-language-server", "start" },
					filetypes = { "sh", "bash" },
				},
			},
			setup = {
				clangd = function(_, opts)
					opts.capabilities.offsetEncoding = { "utf-16" }
					opts.cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--suggest-missing-includes",
						"--completion-style=detailed",
						"--log=error",
						"--pretty",
						"--limit-results=100",
					}
				end,
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "shellcheck" }, PATH = "append" },
	},
}
