--[[
=====================================================================
                    Neovim Plugins - GitHub Copilot
=====================================================================

This file configures GitHub Copilot AI code completion integration.

PLUGIN OVERVIEW:

  AI Completion:
    - copilot.lua           : GitHub Copilot client
    - blink-copilot         : Copilot source for blink.cmp

CONFIGURATION:

  Copilot is configured to:
  - Use copilot-language-server binary (system-installed)
  - Disable native suggestion/panel (using blink.cmp instead)
  - Enable for markdown and help files

  Blink-copilot integration:
  - max_completions = 3     : Up to 3 Copilot suggestions
  - score_offset = 100      : High priority in completion menu
  - debounce = 200ms        : Delay before requesting completions
  - auto_refresh enabled    : Refresh on cursor movement

COMMANDS:

  :Copilot                  : Open Copilot status/commands

@see lua/plugins/core/coding.lua for blink.cmp configuration
@see https://github.com/zbirenbaum/copilot.lua
]]

return {
  -- ============================================================================
  -- AI CODE COMPLETION
  -- ============================================================================

  --[[
    copilot.lua - GitHub Copilot Client
    
    Provides the core Copilot functionality. Configured to use blink.cmp
    for displaying suggestions rather than native ghost text.
  ]]
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      lsp_binary = 'copilot-language-server',
    },
  },
  {
    'saghen/blink.cmp',
    dependencies = { 'fang2hou/blink-copilot' },
    opts = {
      sources = {
        default = { 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
            opts = {
              max_completions = 3,
              max_attempts = 4,
              kind_name = 'Copilot', ---@type string | false
              kind_icon = ' ', ---@type string | false
              kind_hl = false, ---@type string | false
              debounce = 200, ---@type integer | false
              auto_refresh = {
                backward = true,
                forward = true,
              },
            },
          },
        },
      },
    },
  },
}
