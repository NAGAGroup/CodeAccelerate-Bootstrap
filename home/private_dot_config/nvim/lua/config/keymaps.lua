-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set
map("n", "<leader>snH", "<cmd>lua Snacks.notifier.show_history()<cr>", { desc = "Snacks Notification History" })
map("n", "<leader>uT", "<cmd>lua require('nvchad.themes').open()<cr>", { desc = "NVChad Theme Picker" })

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

	local cmp = require("cmp")
	local name = "cmp_ai"
	local config = cmp.get_config()
	local found = false

	-- Search for the source in the existing sources
	for _, source in ipairs(config.sources) do
		if source.name == name then
			found = true
			break
		end
	end

	-- If the source was not found, add it back
	if not found then
		table.insert(config.sources, { name = name, group_index = 1, priority = 100 })
	end
end

map("n", "<leader>cL", enable_cmp_ai, { desc = "Enable AI Autocompletion" })
