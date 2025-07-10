--[[ 
=====================================================================
          Neovim Configuration - Markdown Language Server
=====================================================================
This module configures the Markdown language server (marksman).
]]

return {
  -- Markdown Language Server
  marksman = {
    settings = {
      marksman = {
        -- Disable snippets for markdown
        enableSnippets = false,
      }
    },
  },
}