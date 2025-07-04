return {
  -- ============================================================================
  -- CODE QUALITY (FORMATTING & LINTING)
  -- ============================================================================

  -- Code formatting
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>cF',
        function()
          require('conform').format { formatters = { 'injected' }, timeout_ms = 3000 }
        end,
        mode = { 'n', 'v' },
        desc = 'Format Injected Langs',
      },
      {
        '<leader>uF',
        function()
          local ConformOptions = NvimLuaUtils.conform_options
          ConformOptions.format_on_save_enabled = not ConformOptions.format_on_save_enabled
          if ConformOptions.format_on_save_enabled then
            vim.notify('Format on Save Enabled', vim.log.levels.INFO)
          else
            vim.notify('Format on Save Disabled', vim.log.levels.WARN)
          end
        end,
        mode = { 'n' },
        desc = 'Enable/Disable Format on Save',
      },
    },
    opts = function()
      local ConformOptions = NvimLuaUtils.conform_options or {}
      ConformOptions.format_on_save_enabled = ConformOptions.format_on_save_enabled or true
      NvimLuaUtils.conform_options = ConformOptions

      -- Prettier utility functions
      local supported_filetypes = {
        'css',
        'graphql',
        'handlebars',
        'html',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'less',
        'markdown',
        'markdown.mdx',
        'scss',
        'typescript',
        'typescriptreact',
        'vue',
        'yaml',
      }

      local function has_prettier_config(ctx)
        vim.fn.system { 'prettier', '--find-config-path', ctx.filename }
        return vim.v.shell_error == 0
      end

      local function has_prettier_parser(ctx)
        local ft = vim.bo[ctx.buf].filetype
        -- default filetypes are always supported
        if vim.tbl_contains(supported_filetypes, ft) then
          return true
        end
        -- otherwise, check if a parser can be inferred
        local ret = vim.fn.system { 'prettier', '--file-info', ctx.filename }
        local ok, parser = pcall(function()
          return vim.fn.json_decode(ret).inferredParser
        end)
        return ok and parser and parser ~= vim.NIL
      end

      ---@type conform.setupOpts
      return {
        default_format_opts = {
          timeout_ms = 3000,
          async = false,
          quiet = false,
          lsp_format = 'fallback',
        },
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'black' },
          toml = { 'taplo' },
          markdown = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          -- Prettier for web technologies
          css = { 'prettier' },
          graphql = { 'prettier' },
          handlebars = { 'prettier' },
          html = { 'prettier' },
          javascript = { 'prettier' },
          javascriptreact = { 'prettier' },
          json = { 'prettier' },
          jsonc = { 'prettier' },
          less = { 'prettier' },
          scss = { 'prettier' },
          typescript = { 'prettier' },
          typescriptreact = { 'prettier' },
          vue = { 'prettier' },
          yaml = { 'prettier' },
        },
        formatters = {
          injected = { options = { ignore_errors = true } },
          prettier = {
            condition = function(_, ctx)
              return has_prettier_parser(ctx)
            end,
          },
          ['markdown-toc'] = {
            condition = function(_, ctx)
              for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
                if line:find '<!%-%- toc %-%->' then
                  return true
                end
              end
            end,
          },
          ['markdownlint-cli2'] = {
            condition = function(_, ctx)
              local diag = vim.tbl_filter(function(d)
                return d.source == 'markdownlint'
              end, vim.diagnostic.get(ctx.buf))
              return #diag > 0
            end,
          },
        },
      }
    end,
    config = function(_, opts)
      require('conform').setup(opts)
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*',
        callback = function(args)
          local conform = require 'conform'
          -- Check if formatting is available for this buffer
          local formatters = conform.list_formatters(args.buf)
          local ConformOptions = NvimLuaUtils.conform_options
          if #formatters > 0 and ConformOptions.format_on_save_enabled then
            conform.format { bufnr = args.buf }
          end
        end,
      })
    end,
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufNewFile', 'BufWritePost' },
    opts = {
      events = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
      linters_by_ft = {
        fish = { 'fish' },
        cmake = { 'cmakelint' },
        dockerfile = { 'hadolint' },
        markdown = { 'markdownlint-cli2' },
      },
      linters = {},
    },
    config = function(_, opts)
      local lint = require 'lint'
      for name, linter in pairs(opts.linters) do
        if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
          lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
          if type(linter.prepend_args) == 'table' then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      local function debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      local function lint_buffer()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft['_'] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft['*'] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          return linter and not (type(linter) == 'table' and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
        callback = debounce(100, lint_buffer),
      })
    end,
  },
}
