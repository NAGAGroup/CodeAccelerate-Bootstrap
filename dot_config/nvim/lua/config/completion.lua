-- =============================================================================
-- completion.lua — blink.cmp + mini.snippets + friendly-snippets
-- =============================================================================

-- mini.snippets (with friendly-snippets via gen_loader.from_lang)
local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		gen_loader.from_lang(),
	},
})

-- blink.cmp
require("blink.cmp").setup({
	snippets = { preset = "mini_snippets" },

	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		per_filetype = {
			markdown = { "markview", "lsp", "path", "snippets", "buffer" },
		},
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
			markview = {
				name = "markview",
				module = "blink-markview",
			},
		},
	},

	keymap = {
		preset = "none",
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
		["<C-e>"] = { "hide", "fallback" },
		["<C-y>"] = { "select_and_accept" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	},

	fuzzy = {
		implementation = "lua",
		prebuilt_binaries = { download = false },
	},

	completion = {
		menu = { border = "rounded" },
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

-- markview blink integration flag (must be set before markview.setup in markdown.lua)
vim.g.markview_blink_loaded = true
