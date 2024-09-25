return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				cmake = { "cmake_format" },
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "cmakelang" } },
	},
}
