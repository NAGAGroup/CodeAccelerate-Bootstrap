-- return {
--   "robitx/gp.nvim",
--   -- A plugin configuration to enhance your coding experience!
--   config = function()
--     -- Define custom configurations for each provider
--     local conf = {
--       providers = {
--         -- Use OpenAI models for AI-driven suggestions
--         openai = {},
--
--         -- Utilize Azure's cognitive services for intelligent completions
--         azure = {},
--
--         -- Activate CoPilot-powered code completion
--         copilot = {},
--
--         -- Disable or customize codellama-powered completions
--         codellama = {
--           disable = false,
--           endpoint = "http://localhost:11434/api/chat" -- Secret key for authentication
--         },
--
--         -- Integrate with LmStudio's language models
--         lmstudio = {},
--
--         -- Leverage Google AI services for enhanced code suggestions
--         googleai = {},
--
--         -- Access PPLX's proprietary programming knowledge base
--         pplx = {},
--
--         -- Tap into Anthropic's AI-driven coding assistance
--         anthropic = {}
--       },
--       agents = {
--         {
--           provider = "codellama",
--           name = "codellama",
--           chat = true,
--           command = false,
--           -- system prompt (use this to specify the persona/role of the AI)
--           system_prompt =
--           "You are a general code assistant",
--           -- string with model name or table with model name and parameters
--           model = {
--             model = "codellama:7b",
--           }
--         }
--       }
--     }
--
--     -- Load the GP plugin with custom configurations
--     require("gp").setup(conf)
--
--     -- Define shortcuts for an enhanced user experience (see Documentation/Readme)
--   end
-- }



return {
  "codecompanion.nvim",
  dependencies = {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim"
    },
    config = true
  },

  config = function()
    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = "codellama",
          roles = {
            llm = "assistant", -- The markdown header content for the LLM's responses
            user = "user",     -- The markdown header for your questions
          },
        },
        inline = {
          adapter = "codellama"
        },
        agent = {
          adapter = "codellama",
        },
      },
      adapters = {
        codellama = require("codecompanion.adapters").extend("ollama", {
          name = "codellama", -- Ensure the model is differentiated from Ollama
          schema = {
            model = {
              default = "codellama:7b",
            }
          },
        })
      },
    })
    return true
  end
}
