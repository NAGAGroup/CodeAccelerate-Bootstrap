return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'blink.cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    opts = function()
      return {
        -- Diagnostic configuration
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = {
            spacing = 4,
            source = 'if_many',
            prefix = '●',
          },
          severity_sort = true,
          signs = true,
        },
        -- LSP server configurations
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                codeLens = {
                  enable = true,
                },
                completion = {
                  callSnippet = 'Replace',
                },
                hint = {
                  enable = true,
                  paramType = true,
                },
              },
            },
          },
          -- Add more server configurations here
          -- tsserver = {},
          -- pyright = {},
        },
        servers_no_install = {},
      }
    end,
    config = function(_, opts)
      -- Setup Mason
      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(opts.servers), -- Ensure all servers in opts are installed
      }

      local servers = opts.servers or {}
      servers = vim.tbl_extend('force', servers, opts.servers_no_install or {})
      opts.servers = servers

      -- Configure diagnostics
      vim.diagnostic.config(opts.diagnostics)

      -- Configure LSP servers
      local lspconfig = require 'lspconfig'
      for server, config in pairs(opts.servers) do
        config = vim.tbl_extend('force', {
          on_attach = function(client, bufnr)
            -- Attach keymaps
            local keymaps = require 'config.lsp_keymaps' -- Adjust the path as needed
            keymaps.on_attach(client, bufnr)
          end,
        }, config)
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    'mason.nvim',
    { 'mason-org/mason-lspconfig.nvim', config = function() end },
  },
  { 'mason-org/mason-lspconfig.nvim', config = function() end },
  {

    'mason-org/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    build = function()
      if vim.fn.exists ':MasonUpdate' == 2 then
        vim.cmd 'MasonUpdate'
      end
    end,
    opts_extend = { 'ensure_installed' },
    opts = {
      ensure_installed = {
        'stylua',
        'shfmt',
      },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require('mason').setup(opts)
      local mr = require 'mason-registry'
      mr:on('package:install:success', function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require('lazy.core.handler.event').trigger {
            event = 'FileType',
            buf = vim.api.nvim_get_current_buf(),
          }
        end, 100)
      end)

      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },
}
