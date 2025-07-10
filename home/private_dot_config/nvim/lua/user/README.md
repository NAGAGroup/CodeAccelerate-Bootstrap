# User Configuration Directory

This directory is intended for user-specific overrides and customizations. Files in this directory can be modified without affecting the core configuration, making it easier to update the main configuration without losing your personal settings.

## Available Override Files

You can create any of the following files to customize your Neovim experience:

- `options.lua` - Override Neovim options
- `plugins.lua` - Add, remove, or configure plugins
- `keymaps.lua` - Add or modify keymappings
- `autocmds.lua` - Add custom autocommands

## Example: options.lua

```lua
-- Override options
vim.opt.wrap = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10
```

## Example: plugins.lua

```lua
-- Return a table of plugins to be merged with the main plugins
return {
  -- Add new plugins
  {
    "github/copilot.vim",
    event = "InsertEnter",
  },
  
  -- Override existing plugin configs
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        sorting_strategy = "ascending",
      },
    },
  },
}
```

## Example: keymaps.lua

```lua
-- Add custom keymaps
vim.keymap.set('n', '<leader>x', '<cmd>ToggleTerm<CR>', { desc = 'Toggle Terminal' })
```

## Example: autocmds.lua

```lua
-- Add custom autocommands
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = true
  end,
})
```

## Note

This directory is added to `.gitignore`, so your changes won't be tracked by git.