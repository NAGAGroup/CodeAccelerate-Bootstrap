-- return {
-- 	"hrsh7th/nvim-cmp",
-- 	dependencies = {
-- 		{ "tzachar/cmp-ai", dependencies = "nvim-lua/plenary.nvim" },
-- 	},
-- 	opts = function(_, opts)
-- 		opts.sources = opts.sources or {}
-- 		table.insert(opts.sources, { name = "cmp_ai" })
--
-- 		-- Tabby source via cmp-ai
--
-- 		local cmp_ai = require("cmp_ai.config")
--
-- 		cmp_ai:setup({
-- 			max_lines = 1000,
-- 			provider = "Tabby",
-- 			notify = false,
-- 			provider_options = {
-- 				-- These are optional
-- 				-- user = 'yourusername',
-- 				-- temperature = 0.2,
-- 				-- seed = 'randomstring',
-- 			},
-- 			notify_callback = function()
-- 				-- vim.notify(msg)
-- 			end,
-- 			run_on_every_keystroke = true,
-- 			ignored_file_types = {
-- 				-- default is not to ignore
-- 				-- uncomment to ignore in lua:
-- 				-- lua = true
-- 			},
-- 		})
-- 	end,
-- }
return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		{ "tzachar/cmp-ai", dependencies = "nvim-lua/plenary.nvim" },
	},
}
