return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				bashls = {
					cmd = { "bash-language-server", "start" },
					filetypes = { "sh", "bash" },
				},
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "shellcheck" } },
	},
}
