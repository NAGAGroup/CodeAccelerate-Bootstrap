return {
    "robitx/gp.nvim",
    -- A plugin configuration to enhance your coding experience!
    config = function()
        -- Define custom configurations for each provider
        local conf = {
            providers = {
                -- Use OpenAI models for AI-driven suggestions
                openai = {},

                -- Utilize Azure's cognitive services for intelligent completions
                azure = {},

                -- Activate CoPilot-powered code completion
                copilot = {},

                -- Disable or customize OLLAMA-powered completions
                ollama = {
                    disable = false,
                    endpoint = "http://localhost:8080/v1/chat/completions",
                    secret = "auth_238d242604964a7eb1fd60d74c729abf" -- Secret key for authentication
                },

                -- Integrate with LmStudio's language models
                lmstudio = {},

                -- Leverage Google AI services for enhanced code suggestions
                googleai = {},

                -- Access PPLX's proprietary programming knowledge base
                pplx = {},

                -- Tap into Anthropic's AI-driven coding assistance
                anthropic = {}
            },
            agents = {
                {
                    provider = "ollama",
                    name = "TabbyChat",
                    chat = true,
                    command = false,
                    -- system prompt (use this to specify the persona/role of the AI)
                    system_prompt = require("gp.defaults").chat_system_prompt,
                    -- string with model name or table with model name and parameters
                    model = {
                        model = "DeepseekCoder-6.7B",
                        temperature = 0.6,
                        top_p = 1,
                        min_p = 0.05
                    }
                }, {
                    provider = "ollama",
                    name = "TabbyCommand",
                    chat = false,
                    command = true,
                    -- system prompt (use this to specify the persona/role of the AI)
                    system_prompt = require("gp.defaults").code_system_prompt,
                    -- string with model name or table with model name and parameters
                    model = {
                        model = "DeepseekCoder-6.7B",
                        temperature = 0.6,
                        top_p = 1,
                        min_p = 0.05
                    }
                }
            }
        }

        -- Load the GP plugin with custom configurations
        require("gp").setup(conf)

        -- Define shortcuts for an enhanced user experience (see Documentation/Readme)
    end
}

