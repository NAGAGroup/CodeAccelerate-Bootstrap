-- UI layer plugins

local add = MiniDeps.add

-- Dependencies for NvChad
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

-- Add session restore button
startify.section.top_buttons.val = {
	startify.button("s", "  Restore session", "<cmd>AutoSession search<CR>"),
	startify.button("e", "  New file", "<cmd>ene<CR>"),
	startify.button("f", "  Find file", "<cmd>FzfLua files<CR>"),
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

-- NvChad UI (provides nvconfig module for base46)
add("nvchad/ui")
-- Matches NvChad's install docs: nvchad/ui expects this to initialize and read chadrc.lua
require("nvchad")

-- Colorscheme (base46)
-- CRITICAL: Must load BEFORE NvChad UI to ensure highlight cache exists
add({
	source = "nvchad/base46",
})
require("base46").load_all_highlights()

-- Theme switcher (optional)
add("nvchad/volt")
add("nvchad/minty")
vim.keymap.set("n", "<leader>th", function() require("nvchad.themes").open() end, { desc = "Theme picker" })

-- Completion (blink.cmp)
add({
	source = "saghen/blink.cmp",
	checkout = "v1.9.1",
	depends = { "rafamadriz/friendly-snippets" },
})

require("blink.cmp").setup({
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = {
			force_version = "v1.9.1",
		},
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
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
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

-- Statusline (lualine)
-- later(function()
-- 	add("nvim-lualine/lualine.nvim")
--
-- 	require("lualine").setup({
-- 		options = {
-- 			theme = "auto",
-- 			component_separators = { left = "", right = "" },
-- 			section_separators = { left = "", right = "" },
-- 			globalstatus = true,
-- 		},
-- 		sections = {
-- 			lualine_a = { "mode" },
-- 			lualine_b = { "branch", "diff", "diagnostics" },
-- 			lualine_c = { { "filename", path = 1 } },
-- 			lualine_x = { "encoding", "fileformat", "filetype" },
-- 			lualine_y = { "progress" },
-- 			lualine_z = { "location" },
-- 		},
-- 	})
-- end)

-- Buffer tabs (bufferline)
add("akinsho/bufferline.nvim")

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
			local icon = level:match("error") and " " or " "
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

-- Keymap hints (which-key)
add("folke/which-key.nvim")

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

-- Indent guides (ibl)
add("lukas-reineke/indent-blankline.nvim")

require("ibl").setup({
	indent = {
		char = "│",
		tab_char = "│",
	},
	scope = {
		enabled = true,
		show_start = true,
		show_end = false,
	},
	exclude = {
		filetypes = {
			"help",
			"alpha",
			"dashboard",
			"neo-tree",
			"Trouble",
			"lazy",
			"mason",
			"notify",
			"toggleterm",
			"dapui_scopes",
			"dapui_breakpoints",
			"dapui_stacks",
			"dapui_watches",
			"dapui_console",
			"dapui_repl",
		},
	},
})

-- Notifications (nvim-notify)
add("rcarriga/nvim-notify")

local notify = require("notify")
notify.setup({
	stages = "fade_in_slide_out",
	timeout = 3000,
	background_colour = "#000000",
	icons = {
		ERROR = "",
		WARN = "",
		INFO = "",
		DEBUG = "",
		TRACE = "",
	},
})
vim.notify = notify

-- Diagnostics UI (Trouble)
add("folke/trouble.nvim")

require("trouble").setup({
	use_diagnostic_signs = true,
})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Toggle diagnostics" })
vim.keymap.set(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
	{ desc = "Buffer diagnostics" }
)
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", { desc = "Symbols" })
vim.keymap.set(
	"n",
	"<leader>xl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<CR>",
	{ desc = "LSP references" }
)
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<CR>", { desc = "Location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<CR>", { desc = "Quickfix list" })
