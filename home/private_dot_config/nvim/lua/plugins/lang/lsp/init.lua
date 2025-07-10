--[[ 
=====================================================================
         Neovim Configuration - LSP Configuration Loader
=====================================================================
This module loads LSP configurations and sets up common LSP features.
]]

return {
  -- Main LSP Configuration
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason for LSP management
      {
        'mason-org/mason.nvim',
        cmd = 'Mason',
        keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- LSP UI enhancements
      { 'j-hui/fidget.nvim', opts = {} },

      -- LSP completion capabilities
      'saghen/blink.cmp',
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      -- Setup diagnostics
      -- Load diagnostics module
      require('config.diagnostics').setup()
      
      -- Get LSP keymaps module
      local lsp_keymaps = require('config.keymaps.lsp')
      
      -- LSP capabilities helper from utils
      local lsp_utils = require('utils.lsp')
      local capabilities = lsp_utils.get_capabilities()
      
      -- LSP servers to install
      local ensure_installed = {}
      for server, _ in pairs(opts.servers) do
        if server ~= "nushell" then -- Skip servers we don't want to install with Mason
          table.insert(ensure_installed, server)
        end
      end
      
      -- Add formatters and linters
      vim.list_extend(ensure_installed, opts.ensure_installed or {})
      
      -- Setup Mason
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        automatic_installation = true,
      })
      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
        auto_update = true,
      })
      
      -- Helper function to setup LSP servers
      local function setup_server(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          flags = { debounce_text_changes = 150 },
        }, opts.servers[server] or {})
        
        -- On attach callback to setup keymaps and other customizations
        server_opts.on_attach = function(client, bufnr)
          -- Add LSP keymaps
          lsp_keymaps.on_attach(client, bufnr)
          
          -- Format on save if client supports it
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("LspFormatting_" .. bufnr, { clear = true }),
              buffer = bufnr,
              callback = function()
                if vim.g.format_on_save == true then
                  vim.lsp.buf.format({ bufnr = bufnr })
                end
              end,
            })
          end
        end
        
        -- Use server-specific setup function if defined
        if opts.setup[server] then
          if opts.setup[server](server_opts) then
            return
          end
        end
        
        -- Default setup for the server
        require('lspconfig')[server].setup(server_opts)
      end
      
      -- Setup LSP for non-Mason servers
      for server, server_opts in pairs(opts.servers_no_install or {}) do
        local options = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, server_opts or {})
        require('lspconfig')[server].setup(options)
      end
      
      -- Setup all servers from Mason
      require('mason-lspconfig').setup_handlers({
        function(server)
          setup_server(server)
        end,
      })
    end,
    -- Import language-specific configs
    opts = function()
      return {
        -- Import language-specific configurations
        servers_no_install = require('plugins.lang.lsp.nushell'),
        servers = vim.tbl_deep_extend("force", 
          require('plugins.lang.lsp.lua'),
          require('plugins.lang.lsp.c'),
          require('plugins.lang.lsp.web'),
          require('plugins.lang.lsp.markdown')
        ),
        -- Special setup handlers for specific servers
        setup = {
          clangd = function(opts)
            local clangd_opts = {
              inlay_hints = { inline = false },
              ast = {
                role_icons = {
                  type = '',
                  declaration = '',
                  expression = '',
                  specifier = '',
                  statement = '',
                  ['template argument'] = '',
                },
                kind_icons = {
                  Compound = '',
                  Recovery = '',
                  TranslationUnit = '',
                  PackExpansion = '',
                  TemplateTypeParm = '',
                  TemplateTemplateParm = '',
                  TemplateParamObject = '',
                },
              },
            }
            require('clangd_extensions').setup(vim.tbl_deep_extend('force', clangd_opts or {}, { server = opts }))
            return false
          end,
        },
        -- Tools to install with Mason
        ensure_installed = {
          -- Formatters
          'stylua',
          'shfmt',
          'prettier',
          -- Linters
          'eslint_d',
          'luacheck',
        },
      }
    end
  },
  
  -- Extensions for specific language servers
  { import = "plugins.lang.lsp.extensions" }
}