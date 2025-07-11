return {
  -- ============================================================================
  -- LSP & COMPLETION
  -- ============================================================================
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    opts = {
      -- LSP server configurations
      servers_no_install = {},
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
      setup = {},
      ensure_installed = {
        -- Linters
        'hadolint',
      },
    },
  },

  -- ============================================================================
  -- CODE QUALITY (FORMATTING & LINTING)
  -- ============================================================================

  -- Code formatting
  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {},
      formatters = {},
    },
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        dockerfile = { 'hadolint' },
      },
      linters = {},
    },
  },

  -- Debug Adapter Protocol
  {
    'mfussenegger/nvim-dap',
    opts = function() end,
  },

  -- mason.nvim integration
  {
    'jay-babu/mason-nvim-dap.nvim',
    opts = {
      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
      },
    },
  },

  -- ============================================================================
  -- EDITOR CORE
  -- ============================================================================

  -- Treesitter syntax highlighting and parsing
  {
    'nvim-treesitter/nvim-treesitter',
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      ensure_installed = {
        'dockerfile',
      },
    },
  },
}
