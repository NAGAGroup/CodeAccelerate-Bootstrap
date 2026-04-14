-- UI layer plugins

local add = MiniDeps.add

-- Icons (required by many plugins)
add("nvim-lua/plenary.nvim")
add("nvim-tree/nvim-web-devicons")

-- alpha-nvim dashboard
add({
	source = "goolord/alpha-nvim",
	depends = { "nvim-tree/nvim-web-devicons" },
})

local alpha = require("alpha")
local startify = require("alpha.themes.startify")

-- Customize startify
startify.section.header.val = {
	[[                                   ]],
	[[   ███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
	[[   ████╗  ██║██║   ██║██║████╗ ████║]],
	[[   ██╔██╗ ██║██║   ██║██║██╔████╔██║]],
	[[   ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
	[[   ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
	[[   ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
	[[                                   ]],
}

-- Helper for root-aware pickers
local function root()
	local r = require("core.root")
	return r.detect and r.detect() or vim.fn.getcwd()
end

startify.section.top_buttons.val = {
	startify.button("s", "  Restore session", "<cmd>AutoSession search<CR>"),
	startify.button("e", "  New file", "<cmd>ene<CR>"),
	startify.button("f", "  Find file", function()
		Snacks.picker.files({ cwd = root() })
	end),
	startify.button("q", "  Quit", "<cmd>qa<CR>"),
}

alpha.setup(startify.config)

-- Auto-close alpha when opening file
vim.api.nvim_create_autocmd("User", {
	pattern = "AlphaReady",
	callback = function()
		vim.opt.showtabline = 0
	end,
})

vim.api.nvim_create_autocmd("BufRead", {
	callback = function()
		vim.opt.showtabline = 2
	end,
})

-- Colorscheme
add({ source = "Shatur/neovim-ayu" })
require("ayu").setup({
	mirage = true,
	terminal = true,
	overrides = {},
})
vim.cmd.colorscheme("ayu-mirage")

-- Statusline (lualine)
add({ source = "nvim-lualine/lualine.nvim" })
require("lualine").setup({
	options = {
		theme = "ayu_mirage",
		globalstatus = true,
		section_separators = { left = "", right = "" },
		component_separators = { left = "", right = "" },
		disabled_filetypes = { statusline = { "alpha" } },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", path = 1 } },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
})

-- Completion (blink.cmp)
add({
	source = "saghen/blink.cmp",
	checkout = "v1.9.1",
	depends = { "rafamadriz/friendly-snippets" },
})

-- Blink-copilot provider
add("fang2hou/blink-copilot")

local ok, err = pcall(function()
	require("blink.cmp").setup({
		fuzzy = {
			implementation = "prefer_rust",
		},
		keymap = {
			preset = "default",
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-y>"] = { "select_and_accept" },
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "copilot" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-copilot",
					score_offset = 100,
					async = true,
				},
			},
		},
		completion = {
			menu = {
				border = "rounded",
				draw = {
					columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = { border = "rounded" },
			},
		},
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},
	})
end)
if not ok then
	vim.notify("blink.cmp setup failed: " .. tostring(err), vim.log.levels.WARN)
end

-- Buffer tabs (bufferline)
add("akinsho/bufferline.nvim")

MiniDeps.later(function()
	require("bufferline").setup({
		options = {
			mode = "buffers",
			numbers = "none",
			close_command = "bdelete! %d",
			right_mouse_command = "bdelete! %d",
			left_mouse_command = "buffer %d",
			middle_mouse_command = nil,
			indicator = {
				style = "icon",
				icon = "▎",
			},
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					highlight = "Directory",
					text_align = "left",
				},
			},
			show_buffer_close_icons = true,
			show_close_icon = true,
			separator_style = "thin",
			always_show_bufferline = true,
		},
	})

	-- Buffer navigation keymaps
	vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
	vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
end)

-- Keymap hints (which-key)
add("folke/which-key.nvim")

MiniDeps.later(function()
	require("which-key").setup({
		plugins = {
			marks = true,
			registers = true,
			spelling = { enabled = true },
			presets = {
				operators = true,
				motions = true,
				text_objects = true,
				windows = true,
				nav = true,
				z = true,
				g = true,
			},
		},
		win = {
			border = "rounded",
		},
	})

	require("which-key").add({
		{ "<leader>c", group = "Code" },
		{ "<leader>cm", group = "CMake" },
		{ "<leader>f", group = "Find/Search" },
		{ "<leader>s", group = "Search" },
		{ "<leader>t", group = "Test" },
		{ "<leader>g", group = "Git" },
		{ "<leader>x", group = "Diagnostics/Trouble" },
		{ "<leader>q", group = "File/Session" },
		{ "<leader>w", group = "File/Session" },
		{ "<leader>d", group = "Debug" },
		{ "<leader>r", group = "Refactor" },
		{ "<leader>b", group = "Buffer" },
		{ "<leader>y", group = "Yank" },
		{ "<leader>a", group = "Harpoon/Add" },
		{ "<leader>S", group = "Session" },
		{ "<leader>u", group = "UI Toggles" },
	})
end)

-- Indent guides are provided by snacks.indent (loaded in plugins.navigation)
-- Notifications are provided by snacks.notifier (loaded in plugins.navigation)

-- Diagnostics UI (Trouble)
add("folke/trouble.nvim")

require("trouble").setup({
	use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Symbols" })
vim.keymap.set(
	"n",
	"<leader>xl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
	{ desc = "LSP references" }
)
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
