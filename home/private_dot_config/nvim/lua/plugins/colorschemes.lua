-- return {
-- {
--     "olimorris/onedarkpro.nvim",
--     priority = 1000 -- Ensure it loads first
-- },
-- {
--     "rebelot/kanagawa.nvim",
--     priority = 1000 -- Ensure it loads first
-- }, {"LazyVim/LazyVim", opts = {colorscheme = "kanagawa-wave"}}
-- {
-- 	"oxfist/night-owl.nvim",
-- 	lazy = false, -- make sure we load this during startup if it is your main colorscheme
-- 	priority = 1000, -- make sure to load this before all the other start plugins
-- 	config = function()
-- 		-- load the colorscheme here
-- 		require("night-owl").setup()
-- 		vim.cmd.colorscheme("night-owl")
-- 	end,
-- },
-- {
-- 	"Yazeed1s/oh-lucy.nvim",
-- 	lazy = false, -- make sure we load this during startup if it is your main colorscheme
-- 	priority = 1000, -- make sure to load this before all the other start plugins
-- 	config = function()
-- 		vim.cmd.colorscheme("oh-lucy-evening")
-- 	end,
-- },
-- {
-- 	"scottmckendry/cyberdream.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("cyberdream")
-- 		vim.cmd.colorscheme("cyberdream")
-- 	end,
-- },
-- {
-- 	"AlexvZyl/nordic.nvim",
-- 	lazy = false,
-- 	priority = 1000,
-- 	config = function()
-- 		require("nordic").load()
-- 	end,
-- },
-- }

return {
	{
		"LazyVim/LazyVim",
		opts = {
			-- don't let LazyVim load a colorscheme
			colorscheme = function() end,
		},
	},
}
