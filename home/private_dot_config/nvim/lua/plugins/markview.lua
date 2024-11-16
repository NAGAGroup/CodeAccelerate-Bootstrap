return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- Recommended
		-- ft = "markdown" -- If you decide to lazy-load anyway

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = {
				ensure_installed = { "latex" }, -- Ensure LaTeX Tree-sitter grammar is installed
			},
			"nvim-tree/nvim-web-devicons",
		},
	},
}
