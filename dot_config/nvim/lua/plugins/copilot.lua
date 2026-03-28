local add = MiniDeps.add

-- GitHub Copilot
add({
	source = "zbirenbaum/copilot.lua",
})
require("copilot").setup({
	suggestion = { enabled = false }, -- Disable inline suggestions; use blink.cmp instead
	panel = { enabled = false },      -- Disable panel; use CopilotChat instead
	filetypes = {
		markdown = true,
		help = false,
	},
})

-- Copilot Chat
add({
	source = "CopilotC-Nvim/CopilotChat.nvim",
	depends = { "nvim-lua/plenary.nvim" },
})
require("CopilotChat").setup({
	window = {
		layout = "vertical",
		width = 0.4,
	},
})

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Copilot Chat toggle" })
map("v", "<leader>cc", "<cmd>CopilotChatToggle<CR>", { desc = "Copilot Chat (selection)" })
map("n", "<leader>ce", "<cmd>CopilotChatExplain<CR>", { desc = "Copilot: Explain" })
map("n", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Copilot: Fix" })
map("v", "<leader>cf", "<cmd>CopilotChatFix<CR>", { desc = "Copilot: Fix selection" })
map("n", "<leader>cr", "<cmd>CopilotChatReview<CR>", { desc = "Copilot: Review" })
map("v", "<leader>cr", "<cmd>CopilotChatReview<CR>", { desc = "Copilot: Review selection" })
