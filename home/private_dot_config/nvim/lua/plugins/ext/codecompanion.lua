local vectorcode_opts = {}
local has_vectorcode = vim.fn.executable 'vectorcode' == 1

local plugins = {}

if has_vectorcode then
  table.insert(plugins, {
    'Davidyz/VectorCode',
    version = '*', -- optional, depending on whether you're on nightly or release
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {},
    setup = function(_, opts)
      vectorcode_opts = opts
    end,
  })
end
-- AI Code Companion
table.insert(plugins, {
  'olimorris/codecompanion.nvim',
  lazy = true,
  cmd = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionToggle', 'CodeCompanionInline', 'CodeCompanionAgent' },
  keys = {
    { '<leader>Cc', '<cmd>CodeCompanionChat Toggle<CR>', desc = 'Toggle Chat' },
    { '<leader>Ci', '<cmd>CodeCompanionInline<CR>', desc = 'Inline Completion' },
    { '<leader>Ca', '<cmd>CodeCompanionAgent<CR>', desc = 'Run Agent' },
    { '<leader>Cm', '<cmd>CodeCompanionPickModel<CR>', desc = 'Pick Model' },
  },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },

  opts = {
    strategies = {
      chat = {
        adapter = 'copilot',
        roles = {
          llm = 'CodeCompanion',
          user = 'User',
        },
      },
      inline = { adapter = 'copilot' },
      agent = { adapter = 'copilot' },
    },
    adapters = {
      copilot = function()
        return require('codecompanion.adapters').extend('copilot', {
          schema = {
            model = {
              default = default_model,
            },
          },
        })
      end,
    },
    opts = {
      log_level = 'INFO',
      send_code = true,
      use_default_actions = true,
      use_default_prompt_library = true,
      -- Simplified system prompt
      system_prompt = [[You are an AI programming assistant named "CodeCompanion" integrated into Neovim.

Your core tasks include:
- Answering programming questions and explaining code
- Reviewing and optimizing code in the current buffer
- Generating unit tests and fixing test failures
- Supporting project setup and Neovim configuration
- Assisting with technical writing (LaTeX, Markdown)
- Summarizing research topics (graphics, numerical analysis, physics simulation)

When responding:
- Follow user instructions precisely
- Use Markdown formatting with language-specific code blocks
- Keep programming responses concise, technical writing more detailed
- Analyze complex problems step-by-step
- Avoid line numbers and triple backticks around entire responses
- Limit to one response per user prompt]],
    },
  },
  setup = function(_, opts)
    -- Define available Copilot models with friendly names
    local MODELS = {
      sonnet = 'claude-3.7-sonnet',
      haiku = 'claude-3.5-haiku',
      opus = 'claude-3.5-opus',
      gpt4 = 'gpt-4o',
    }

    -- Default model to use
    local default_model = MODELS.sonnet

    -- Update adapter with the selected model
    local function update_adapter_model(model)
      default_model = model
      require('codecompanion').setup {
        adapters = {
          copilot = function()
            return require('codecompanion.adapters').extend('copilot', {
              schema = {
                model = {
                  default = default_model,
                },
              },
            })
          end,
        },
      }
    end

    -- Find model name by value
    local function get_model_name(model_value)
      for name, value in pairs(MODELS) do
        if value == model_value then
          return name
        end
      end
      return 'unknown'
    end

    -- Command to pick a model using Telescope
    vim.api.nvim_create_user_command('CodeCompanionPickModel', function()
      local model_entries = {}
      local model_names = {}

      -- Create entries for selection
      for name, model in pairs(MODELS) do
        local display_name = name .. ' (' .. model .. ')' .. (model == default_model and ' ✓' or '')
        table.insert(model_entries, {
          name = name,
          model = model,
          display = display_name,
        })
        table.insert(model_names, display_name)
      end

      vim.ui.select(model_entries, {
        prompt = 'Select CodeCompanion Model',
        format_item = function(item)
          return item.display
        end,
      }, function(selection)
        if selection then
          local model = selection.model
          update_adapter_model(model)
          vim.notify('CodeCompanion: Switched to ' .. selection.name .. ' (' .. model .. ')', vim.log.levels.INFO)
        end
      end)
    end, {})

    -- Command to switch between models
    vim.api.nvim_create_user_command('CodeCompanionSwitchModel', function(opts)
      local model_name = opts.args
      if MODELS[model_name] then
        update_adapter_model(MODELS[model_name])

        vim.notify('CodeCompanion: Switched to ' .. model_name .. ' (' .. default_model .. ')', vim.log.levels.INFO)
      else
        local available_models = {}
        for name, _ in pairs(MODELS) do
          table.insert(available_models, name)
        end
        vim.notify('Available models: ' .. table.concat(available_models, ', '), vim.log.levels.ERROR)
      end
    end, {
      nargs = 1,
      complete = function()
        local completions = {}
        for name, _ in pairs(MODELS) do
          table.insert(completions, name)
        end
        return completions
      end,
    })

    -- Command to show current model
    vim.api.nvim_create_user_command('CodeCompanionCurrentModel', function()
      local model_name = get_model_name(default_model)
      vim.notify('Current model: ' .. model_name .. ' (' .. default_model .. ')', vim.log.levels.INFO)
    end, {})

    -- Setup the plugin
    if has_vectorcode then
      require('vectorcode').setup(vectorcode_opts)
    end
    require('codecompanion').setup(opts)
  end,
})

if has_vectorcode then
  table.insert(plugins, {
    'olimorris/codecompanion.nvim',
    dependencies = {
      'Davidyz/VectorCode',
    },
    ---@module "vectorcode"
    opts = {
      extensions = {
        vectorcode = {
          ---@type VectorCode.CodeCompanion.ExtensionOpts
          opts = {
            tool_group = {
              -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
              enabled = true,
              -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
              -- if you use @vectorcode_vectorise, it'll be very handy to include
              -- `file_search` here.
              extras = {},
              collapse = false, -- whether the individual tools should be shown in the chat
            },
            tool_opts = {
              ---@type VectorCode.CodeCompanion.ToolOpts
              ['*'] = {},
              ---@type VectorCode.CodeCompanion.LsToolOpts
              ls = {},
              ---@type VectorCode.CodeCompanion.VectoriseToolOpts
              vectorise = {},
              ---@type VectorCode.CodeCompanion.QueryToolOpts
              query = {
                max_num = { chunk = -1, document = -1 },
                default_num = { chunk = 50, document = 10 },
                include_stderr = false,
                use_lsp = false,
                no_duplicate = true,
                chunk_mode = false,
                ---@type VectorCode.CodeCompanion.SummariseOpts
                summarise = {
                  ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
                  enabled = false,
                  adapter = nil,
                  query_augmented = true,
                },
              },
              files_ls = {},
              files_rm = {},
            },
          },
        },
      },
    },
  })
end
return plugins
