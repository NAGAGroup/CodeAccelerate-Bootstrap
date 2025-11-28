--[[
=====================================================================
                    Neovim Plugins - Base Language Support
=====================================================================

This file configures language-specific plugins that provide enhanced
support for various file formats and languages.

PLUGIN OVERVIEW:

  Markdown:
    - markview.nvim         : Rich markdown preview and rendering

SUPPORTED FILETYPES:

  markview.nvim:
    - markdown              : Standard markdown files
    - quarto                : Quarto documents
    - rmd                   : R Markdown documents

@see lua/plugins/lang/c_lang.lua for C/C++ specific plugins
@see https://github.com/OXY2DEV/markview.nvim
]]

-- ============================================================================
-- BASE LANGUAGE SUPPORT
-- Language-specific plugins that are not part of core functionality
-- ============================================================================
return {
  -- Markdown preview and rendering
  {
    'OXY2DEV/markview.nvim',
    ft = { 'markdown', 'quarto', 'rmd' },
    priority = 49,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'saghen/blink.cmp',
    },
    opts = {
      preview = {
        filetypes = { 'markdown', 'quarto', 'rmd' },
        ignore_buftypes = {},
      },
    },
  },
}
