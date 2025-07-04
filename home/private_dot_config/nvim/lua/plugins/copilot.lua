return {
  -- AI code completion engine
  {
    'zbirenbaum/copilot.lua',
    dependencies = { 'blink.cmp' },
    event = { 'InsertEnter' },
    cmd = { 'Copilot' },
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
      lsp_binary = 'copilot-language-server',
    },
  },
}
