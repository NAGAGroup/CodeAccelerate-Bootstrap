-- =============================================================================
-- ui.lua — snacks.setup (ALL modules) + milli dashboard + lualine + which-key + trouble
-- =============================================================================
-- Runs before navigation.lua and editing.lua so Snacks.* is available.
-- =============================================================================

-- mini.icons — icon provider (replaces nvim-web-devicons; mock for plugins
-- that still require("nvim-web-devicons"), e.g. lualine)
require("mini.icons").setup({})
MiniIcons.mock_nvim_web_devicons()

-- milli splash for snacks.dashboard header
local splash_ok, splash = pcall(function()
	return require("milli").load({ splash = "fire" })
end)
local header = splash_ok and table.concat(splash.frames[1], "\n") or "Neovim"

require("snacks").setup({
	dashboard = {
		enabled = true,
		preset = { header = header },
		sections = {
			{ section = "header", padding = 1 },
			{ section = "keys", gap = 1, padding = 1 },
			{ section = "recent_files", cwd = true, limit = 5, padding = 1 },
			-- NOTE: no { section = "startup" } — it requires lazy.nvim
			-- (require("lazy.stats")) and crashes the dashboard under vim.pack
			{
				text = { { "  NVIM " .. tostring(vim.version()), hl = "footer" } },
				align = "center",
			},
		},
	},
	explorer = { enabled = true, replace_netrw = true },
	indent = { enabled = true, char = "│" },
	notifier = { enabled = true, timeout = 3000, style = "compact" },
	words = { enabled = true },
	bigfile = { enabled = true },
	picker = { enabled = true },
	statuscolumn = { enabled = true },
	input = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	toggle = { enabled = true },
	bufdelete = { enabled = true },
	lazygit = { enabled = true },
	terminal = { enabled = true },
})

-- Start milli animation after snacks.setup()
if splash_ok then
	require("milli").snacks({ splash = "fire", loop = true })
end

-- lualine
require("lualine").setup({
	options = {
		theme = "ayu",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = true,
		disabled_filetypes = {
			statusline = { "snacks_dashboard", "dap-view", "dap-view-term" },
			winbar = { "dap-view", "dap-view-term", "dap-view-hover" },
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})

-- which-key (helix preset)
require("which-key").setup({
	preset = "helix",
	win = { border = "rounded" },
})

-- trouble (v3)
require("trouble").setup({ focus = false })

-- Trouble keymaps
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols" })
vim.keymap.set("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "TODOs" })
