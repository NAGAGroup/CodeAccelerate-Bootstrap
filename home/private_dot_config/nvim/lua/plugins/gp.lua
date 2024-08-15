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
                    endpoint = "http://10.80.54.90:8080/v1/chat/completions",
                    secret = "auth_4e833612755941afbe85a0b3cfcc2840" -- Secret key for authentication
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
                    name = "Tabby",
                    chat = true,
                    command = false,
                    -- system prompt (use this to specify the persona/role of the AI)
                    system_prompt = "You are a general AI assistant.",
                    -- string with model name or table with model name and parameters
                    model = {}
                }
            }
        }

        -- Load the GP plugin with custom configurations
        require("gp").setup(conf)

        -- Define shortcuts for an enhanced user experience (see Documentation/Readme)
    end
}

