return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false,
	},
	{
		"OXY2DEV/markview.nvim",
		lazy = false, -- Recommended
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = {
				ensure_installed = { "latex" }, -- Ensure LaTeX Tree-sitter grammar is installed
			},
			"nvim-tree/nvim-web-devicons",
			"olimorris/codecompanion.nvim",
		},
		setup = function()
			require("markview").setup({
				filetypes = { "markdown", "quarto", "rmd", "codecompanion" },
			})
		end,
	},
}
