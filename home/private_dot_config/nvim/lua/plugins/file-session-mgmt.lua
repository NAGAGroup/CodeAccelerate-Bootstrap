return {
  -- ============================================================================
  -- FILE MANAGEMENT & SESSIONS
  -- ============================================================================

  -- Mini file manager
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>fm',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'Open mini.files (Directory of Current File)',
      },
      {
        '<leader>fM',
        function()
          require('mini.files').open(vim.uv.cwd(), true)
        end,
        desc = 'Open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require('mini.files').refresh { content = { filter = new_filter } }
      end

      local map_split = function(buf_id, lhs, direction, close_on_file)
        local rhs = function()
          local new_target_window
          local cur_target_window = require('mini.files').get_explorer_state().target_window
          if cur_target_window ~= nil then
            vim.api.nvim_win_call(cur_target_window, function()
              vim.cmd('belowright ' .. direction .. ' split')
              new_target_window = vim.api.nvim_get_current_win()
            end)

            require('mini.files').set_target_window(new_target_window)
            require('mini.files').go_in { close_on_file = close_on_file }
          end
        end

        local desc = 'Open in ' .. direction .. ' split'
        if close_on_file then
          desc = desc .. ' and close'
        end
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set('n', opts.mappings and opts.mappings.toggle_hidden or 'g.', toggle_dotfiles, { buffer = buf_id, desc = 'Toggle hidden files' })

          vim.keymap.set('n', opts.mappings and opts.mappings.change_cwd or 'gc', files_set_cwd, { buffer = args.data.buf_id, desc = 'Set cwd' })

          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or '<C-w>s', 'horizontal', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or '<C-w>v', 'vertical', false)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or '<C-w>S', 'horizontal', true)
          map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or '<C-w>V', 'vertical', true)
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event)
          Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end,
  },

  -- Surround text objects
  {
    'echasnovski/mini.surround',
    keys = function(_, keys)
      -- Mini surround configuration
      local mini_surround_opts = {
        mappings = {
          add = 'gsa', -- Add surrounding in Normal and Visual modes
          delete = 'gsd', -- Delete surrounding
          find = 'gsf', -- Find surrounding (to the right)
          find_left = 'gsF', -- Find surrounding (to the left)
          highlight = 'gsh', -- Highlight surrounding
          replace = 'gsr', -- Replace surrounding
          update_n_lines = 'gsn', -- Update `n_lines`
        },
      }

      -- Populate the keys based on the user's options
      local mappings = {
        { mini_surround_opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { mini_surround_opts.mappings.delete, desc = 'Delete Surrounding' },
        { mini_surround_opts.mappings.find, desc = 'Find Right Surrounding' },
        { mini_surround_opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { mini_surround_opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { mini_surround_opts.mappings.replace, desc = 'Replace Surrounding' },
        { mini_surround_opts.mappings.update_n_lines, desc = 'Update `MiniSurround.config.n_lines`' },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
      },
    },
  },

  -- Session persistence
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    opts = {},
    keys = {
      {
        '<leader>qs',
        function()
          require('persistence').load()
        end,
        desc = 'Restore Session',
      },
      {
        '<leader>qS',
        function()
          require('persistence').select()
        end,
        desc = 'Select Session',
      },
      {
        '<leader>ql',
        function()
          require('persistence').load { last = true }
        end,
        desc = 'Restore Last Session',
      },
      {
        '<leader>qd',
        function()
          require('persistence').stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
}
