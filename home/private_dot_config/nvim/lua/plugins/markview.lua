return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'OXY2DEV/markview.nvim',
      dependencies = {
        'nvim-tree/nvim-web-devicons',
      },
      opts = {
        ft = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
        preview = {
          filetypes = { 'markdown', 'quarto', 'rmd', 'codecompanion' },
          buf_ignore = {},
        },
      },
    },
    opts = {
      ensure_installed = { 'latex' }, -- Ensure LaTeX Tree-sitter grammar is installed
    },
  },
}
