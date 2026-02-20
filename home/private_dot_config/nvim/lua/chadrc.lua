--[[
=====================================================================
                    NvChad Configuration (chadrc.lua)
=====================================================================

This file configures NvChad-specific settings including themes,
UI components, and integration options.

CONFIGURATION SECTIONS:

  base46:
    - theme           : Color scheme (default: 'everblush')
    - transparency    : Background transparency
    - theme_toggle    : Themes for light/dark toggle

  ui:
    - cmp             : Completion menu styling
    - statusline      : Bottom status bar configuration
    - tabufline       : Buffer/tab line (disabled, using bufferline.nvim)

  nvdash:
    - load_on_startup : Dashboard on startup (disabled, using Snacks)
    - header          : ASCII art header
    - buttons         : Dashboard action buttons

  term:
    - Terminal window configuration

  cheatsheet:
    - theme           : Cheatsheet display style
    - excluded_groups : Groups to hide from cheatsheet

  colorify:
    - Color highlighting for hex codes in files

THEME:

  Default theme: 'everblush'
  Toggle themes: 'onedark' / 'one_light'

  To change theme:
    :lua require('nvchad.themes').open()

NOTE: This file merges with any local 'chadrc' module if present,
allowing for machine-specific overrides.

@see lua/plugins/core/ui.lua for base46 plugin loading
@see https://nvchad.com/docs/config/setup
]]

local options = {

	-- ==========================================================================
	-- THEME & HIGHLIGHTS
	-- ==========================================================================
	base46 = {
		theme = "everblush", -- default theme
		hl_add = {},
		hl_override = {},
		integrations = {},
		changed_themes = {},
		transparency = false,
		theme_toggle = { "onedark", "one_light" },
	},

	-- ==========================================================================
	-- UI COMPONENTS
	-- ==========================================================================
	ui = {
		-- Completion menu styling (NvChad's cmp styling, may not be used with blink.cmp)
		cmp = {
			icons_left = false, -- only for non-atom styles!
			style = "default", -- default/flat_light/flat_dark/atom/atom_colored
			abbr_maxwidth = 60,
			format_colors = {
				tailwind = false, -- will work for css lsp too
				icon = "󱓻",
			},
		},

		-- telescope = { style = 'borderless' }, -- Not used (using FzfLua instead)

		-- Status line configuration
		statusline = {
			enabled = true,
			theme = "default", -- default/vscode/vscode_colored/minimal
			-- default/round/block/arrow separators work only for default statusline theme
			-- round and block will work for minimal theme only
			separator_style = "default",
			order = nil,
			modules = nil,
		},

		-- Buffer/tab line (disabled - using bufferline.nvim instead)
		tabufline = {
			enabled = false,
			lazyload = true,
			order = { "treeOffset", "buffers", "tabs", "btns" },
			modules = nil,
			bufwidth = 21,
		},
	},

	-- ==========================================================================
	-- DASHBOARD (disabled - using Snacks dashboard instead)
	-- ==========================================================================
	nvdash = {
		load_on_startup = false,
		header = {
			"                            ",
			"     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
			"   ▄▀███▄     ▄██ █████▀    ",
			"   ██▄▀███▄   ███           ",
			"   ███  ▀███▄ ███           ",
			"   ███    ▀██ ███           ",
			"   ███      ▀ ███           ",
			"   ▀██ █████▄▀█▀▄██████▄    ",
			"     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
			"                            ",
			"     Powered By  eovim    ",
			"                            ",
		},

		buttons = {
			{ txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
			{ txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
			{ txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep" },
			{ txt = "󱥚  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()" },
			{ txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },

			{ txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },

			{
				txt = function()
					local stats = require("lazy").stats()
					local ms = math.floor(stats.startuptime) .. " ms"
					return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
				end,
				hl = "NvDashFooter",
				no_gap = true,
			},

			{ txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
		},
	},

	-- ==========================================================================
	-- TERMINAL
	-- ==========================================================================
	term = {
		winopts = { number = false, relativenumber = false },
		sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
		float = {
			relative = "editor",
			row = 0.3,
			col = 0.25,
			width = 0.5,
			height = 0.4,
			border = "single",
		},
	},

	-- ==========================================================================
	-- LSP & MISC
	-- ==========================================================================
	lsp = { signature = false },

	cheatsheet = {
		theme = "grid", -- simple/grid
		excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
	},

	mason = { pkgs = {}, skip = {} },

	-- Color highlighting for hex codes and LSP color variables
	colorify = {
		enabled = true,
		mode = "virtual", -- fg, bg, virtual
		virt_text = "󱓻 ",
		highlight = { hex = true, lspvars = true },
	},
}

-- Merge with local chadrc overrides if present
local status, chadrc = pcall(require, "chadrc")
return vim.tbl_deep_extend("force", options, status and chadrc or {})
