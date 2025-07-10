--[[ 
=====================================================================
           Neovim Configuration - Lua Language Server
=====================================================================
This module configures the Lua language server (lua_ls).
]]

return {
  lua_ls = {
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
          library = {
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
            [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
            [vim.fn.stdpath 'data' .. '/lazy/lazy.nvim/lua/lazy'] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        codeLens = {
          enable = false, -- Disable for better performance
        },
        completion = {
          callSnippet = 'Replace',
        },
        hint = {
          enable = false, -- Disable inlay hints for better performance
          paramType = false,
        },
        telemetry = {
          enable = false, -- Disable telemetry for better performance
        },
        diagnostics = {
          disable = { 'missing-fields' }, -- Reduce noisy diagnostics
          globals = { 'vim' }, -- Recognize vim as global
        },
        format = {
          enable = false, -- Use external formatter instead
        },
      },
    },
  },
}