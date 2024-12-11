-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set
map("n", "<leader>snH", "<cmd>lua Snacks.notifier.show_history()<cr>", { desc = "Snacks Notification History" })
map("n", "<leader>cAC", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Chat with CodeCompanion" })
-- map("n", "<leader>uT", "<cmd>lua require('nvchad.themes').open()<cr>", { desc = "NVChad Theme Picker" })
