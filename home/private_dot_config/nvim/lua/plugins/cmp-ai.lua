return {
	"nvim-cmp",
	dependencies = { -- this will only be evaluated if nvim-cmp is enabled
		{
			"tzachar/cmp-ai",
			dependencies = "nvim-lua/plenary.nvim",
		},
	},
}
