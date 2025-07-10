return {

  -- AI Code Completion
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
