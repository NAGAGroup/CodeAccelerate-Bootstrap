-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "<c-=>", "<cmd>LLMSuggestion<cr>")
vim.keymap.set("n", "<leader>snh", "<cmd>lua Snacks.notifier.show_history()<cr>")

local function enable_cmp_ai()
	local cmp_ai = require("cmp_ai.config")
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

	local name = "cmp_ai"
	local cmp = require("cmp")
	local config = cmp.get_config()
	local new_sources = vim.deepcopy(config.sources)

	-- Check if the source already exists to prevent duplicates
	for _, source in ipairs(new_sources) do
		if source.name == name then
			return
		end
	end

	table.insert(new_sources, { name = name })
	cmp.setup({ sources = new_sources })

	local compare = require("cmp.config.compare")
	cmp.setup({
		sorting = {
			priority_weight = 2,
			comparators = {
				require("cmp_ai.compare"),
				compare.offset,
				compare.exact,
				compare.score,
				compare.recently_used,
				compare.kind,
				compare.sort_text,
				compare.length,
				compare.order,
			},
		},
	})
end

local map = LazyVim.safe_keymap_set

map("n", "<leader>cL", enable_cmp_ai, { desc = "Enable AI Autocompletion" })
