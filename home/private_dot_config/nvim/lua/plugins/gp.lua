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
                    secret = "auth_e270f8d57f544a9389a2ad176df4af11" -- Secret key for authentication
                },

                -- Integrate with LmStudio's language models
                lmstudio = {},

                -- Leverage Google AI services for enhanced code suggestions
                googleai = {},

                -- Access PPLX's proprietary programming knowledge base
                pplx = {},

                -- Tap into Anthropic's AI-driven coding assistance
                anthropic = {}
            }
        }

        -- Load the GP plugin with custom configurations
        require("gp").setup(conf)

        -- Define shortcuts for an enhanced user experience (see Documentation/Readme)
    end
}

