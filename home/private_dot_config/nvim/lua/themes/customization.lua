--[[
=====================================================================
               Neovim Configuration - Theme Customization
=====================================================================
This module provides theme customization options and overrides for various themes.
]]

local M = {}

-- Theme-specific customization options
M.customizations = {
  -- Catppuccin theme customizations
  catppuccin = function()
    require('catppuccin').setup({
      flavour = 'mocha', -- mocha, macchiato, frappe, latte
      background = { light = 'latte', dark = 'mocha' },
      transparent_background = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
      },
      styles = {
        comments = { 'italic' },
        conditionals = { 'italic' },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = true,
        mini = true,
        treesitter = true,
        which_key = true,
        navic = { enabled = true },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
          },
        },
      },
    })
  end,
  
  -- Tokyonight theme customizations
  tokyonight = function()
    require('tokyonight').setup({
      style = 'storm', -- storm, moon, night, day
      light_style = 'day',
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = 'dark',
        floats = 'dark',
      },
      sidebars = { 'qf', 'help' },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
    })
  end,
  
  -- Gruvbox theme customizations
  gruvbox = function()
    require('gruvbox').setup({
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      invert_signs = false,
      invert_tabline = false,
      invert_intend_guides = false,
      inverse = true,
      contrast = 'hard', -- soft, hard, ''
      palette_overrides = {},
      overrides = {},
      dim_inactive = false,
      transparent_mode = false,
    })
  end,
  
  -- Kanagawa theme customizations
  kanagawa = function()
    require('kanagawa').setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      dimInactive = false,
      terminalColors = true,
      theme = 'dragon', -- wave, dragon, lotus
    })
  end,
  
  -- Nightfox theme customizations
  nightfox = function()
    require('nightfox').setup({
      options = {
        styles = {
          comments = 'italic',
          keywords = 'bold',
          types = 'italic,bold',
        },
        transparent = false,
        terminal_colors = true,
      },
    })
  end,
}

-- Apply customization for a specific theme
function M.apply_customization(theme)
  local base_theme = theme:gsub('-light', ''):gsub('-dark', '')
                         :gsub('-day', ''):gsub('-night', '')
                         :gsub('-latte', '')
  
  local customizer = M.customizations[base_theme]
  if customizer then
    customizer()
  end
end

return M