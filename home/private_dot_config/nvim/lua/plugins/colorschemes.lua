return {
	{
		"LazyVim/LazyVim",
		opts = {
			-- don't let LazyVim load a colorscheme
			colorscheme = function()
				return nil
			end,
		},
	},
}
