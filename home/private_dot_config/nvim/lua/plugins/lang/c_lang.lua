--[[
=====================================================================
                    Neovim Plugins - C/C++ Language Support
=====================================================================

This file configures C/C++ specific plugins that provide enhanced
development experience for C and C++ projects.

PLUGIN OVERVIEW:

  LSP Extensions:
    - clangd_extensions.nvim : Enhanced clangd features (inlay hints, AST)

  Build System:
    - cmake-tools.nvim       : CMake project integration

FEATURES:

  clangd_extensions:
    - Enhanced inlay hints display
    - AST visualization with custom icons
    - Integrated with clangd LSP from coding.lua

  cmake-tools:
    - Auto-loads when CMakeLists.txt is detected
    - Build configuration management
    - Target selection and execution

@see lua/plugins/core/coding.lua for clangd LSP configuration
@see https://github.com/p00f/clangd_extensions.nvim
@see https://github.com/Civitasv/cmake-tools.nvim
]]

-- ============================================================================
-- C/C++ LANGUAGE SUPPORT
-- Language-specific plugins that are not part of core functionality
-- ============================================================================
return {
  -- clangd extensions for enhanced C/C++ support
  {
    'p00f/clangd_extensions.nvim',
    lazy = true,
    config = function() end,
  },

  -- CMake integration
  {
    'Civitasv/cmake-tools.nvim',
    lazy = true,
    init = function()
      local loaded = false
      local function check()
        local cwd = vim.uv.cwd()
        if vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
          require('lazy').load { plugins = { 'cmake-tools.nvim' } }
          loaded = true
        end
      end
      check()
      vim.api.nvim_create_autocmd('DirChanged', {
        callback = function()
          if not loaded then
            check()
          end
        end,
      })
    end,
    opts = {},
  },
}
