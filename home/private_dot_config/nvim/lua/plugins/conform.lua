return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				cmake = { "cmake_format" },
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "cmakelang" } },
	},
}
