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
	opts = function(_, opts)
		opts.sources = opts.sources or {}

		-- Flag to control enabling/disabling cmp-ai
		local cmp_ai_enabled = true

		-- Function to attempt setup of cmp-ai with error handling
		local function safe_cmp_ai_setup()
			local status, cmp_ai = pcall(require, "cmp_ai.config")
			if not status then
				-- If cmp-ai setup fails (e.g., connection issue), disable it silently
				cmp_ai_enabled = false
				vim.notify("cmp-ai temporarily disabled due to connection error", vim.log.levels.WARN)
				return
			end

			-- Setup cmp-ai as usual if there’s no error
			cmp_ai:setup({
				max_lines = 1000,
				provider = "Tabby",
				notify = false,
				provider_options = {
					-- user = 'yourusername',
					-- temperature = 0.2,
					-- seed = 'randomstring',
				},
				notify_callback = function()
					-- Optionally handle notifications
				end,
				run_on_every_keystroke = true,
				ignored_file_types = {
					-- Example: lua = true
				},
			})
		end

		-- Call the safe setup function
		safe_cmp_ai_setup()

		-- Only insert cmp_ai as a source if enabled
		if cmp_ai_enabled then
			table.insert(opts.sources, { name = "cmp_ai" })
		end
	end,
}
