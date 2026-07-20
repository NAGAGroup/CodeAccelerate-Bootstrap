-- =============================================================================
-- builtins.lua — Neovim 0.12 built-in plugins + ui2
-- =============================================================================

-- undotree (Neovim 0.12 built-in)
vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>U", "<cmd>Undotree<cr>", { desc = "Toggle undotree" })

-- difftool (Neovim 0.12 built-in)
vim.cmd("packadd nvim.difftool")

-- ui2 (experimental — suppresses Press ENTER prompts)
pcall(function()
	require("vim._core.ui2").enable({ enable = true })
end)
