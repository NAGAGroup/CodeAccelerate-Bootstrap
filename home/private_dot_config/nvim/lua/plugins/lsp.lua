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
						"--completion-style=detailed",
						"--log=error",
						"--header-insertion=never", -- Added flag to prevent automatic include insertion
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
