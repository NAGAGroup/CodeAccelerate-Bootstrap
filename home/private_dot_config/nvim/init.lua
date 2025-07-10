-- Create global instance for easy access
_G.NvimLuaUtils = require 'utils.utils'

-- Load core Neovim configurations
require 'config.options' -- Options and settings
require 'config.autocmds' -- Auto commands

-- Bootstrap lazy.nvim and load plugins
require 'config.lazy'

-- Load keymaps after plugins to ensure all plugin-specific mappings work
require 'config.keymaps' -- Key mappings

local function set_picker()
  vim.ui.select = function(items, opts, on_choice)
    local format_item = opts.format_item or tostring
    local choices = {}

    -- Format the items
    for i, item in ipairs(items) do
      choices[i] = format_item(item)
    end

    -- Base fzf options
    local fzf_opts = {
      prompt = opts.prompt or 'Select one of:',
      actions = {
        ['default'] = function(selected)
          if #selected == 0 then
            on_choice(nil, nil)
            return
          end

          -- Find the original item
          for i, choice in ipairs(choices) do
            if choice == selected[1] then
              on_choice(items[i], i)
              return
            end
          end
        end,
      },
    }

    -- Apply the LazyVim styling
    fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
      prompt = ' ',
      winopts = {
        title = ' ' .. vim.trim((opts.prompt or 'Select'):gsub('%s*:%s*$', '')) .. ' ',
        title_pos = 'center',
      },
    })

    -- Handle special case for code actions (based on LazyVim's code)
    if opts.kind == 'codeaction' then
      fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
        winopts = {
          layout = 'vertical',
          -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8 - 16, #choices + 2) + 0.5) + 16,
          width = 0.5,
        },
      })
    else
      -- Default styling for non-codeaction selects
      fzf_opts = vim.tbl_deep_extend('force', fzf_opts, {
        winopts = {
          width = 0.5,
          -- height is number of items, with a max of 80% screen height
          height = math.floor(math.min(vim.o.lines * 0.8, #choices + 2) + 0.5),
        },
      })
    end

    -- Execute fzf with our combined options
    require('fzf-lua').fzf_exec(choices, fzf_opts)
  end
end
set_picker()

-- Load cached theme data
for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
  dofile(vim.g.base46_cache .. v)
end
