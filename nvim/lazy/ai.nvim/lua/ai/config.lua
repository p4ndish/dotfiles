-- AI Configuration for PandaVim
-- Model settings and API key management

local M = {}

-- Default configuration
local default_config = {
    -- Default model to use
    default_model = "gpt-4o",

    -- API configuration
    api = {
        -- OpenAI API
        openai = {
            base_url = "https://api.openai.com/v1",
            models = {
                gpt4 = "gpt-4",
                gpt4_turbo = "gpt-4-turbo",
                gpt4o = "gpt-4o",
                gpt35 = "gpt-3.5-turbo",
            },
        },

        -- Anthropic Claude API
        anthropic = {
            base_url = "https://api.anthropic.com/v1",
            models = {
                claude3_opus = "claude-3-opus-20240229",
                claude3_sonnet = "claude-3-sonnet-20240229",
                claude3_haiku = "claude-3-haiku-20240307",
            },
        },

        -- OpenAI-compatible endpoints
        compatible = {
            models = {},
        },
    },

    -- Model provider selection
    provider = "openai",  -- "openai", "anthropic", or "compatible"

    -- Temperature for completions
    temperature = 0.7,

    -- Maximum tokens in response
    max_tokens = 2048,

    -- System prompt for chat
    system_prompt = "You are an expert programming assistant. Help users write, debug, and understand code.",
}

-- User configuration (will be merged with defaults)
local user_config = {}

--- Get API key for provider
-- @param provider string: Provider name
-- @return string|nil: API key or nil if not set
function M.get_api_key(provider)
    provider = provider or user_config.provider or "openai"
    local env_var = "AI_" .. provider:upper() .. "_API_KEY"
    return os.getenv(env_var) or vim.env[env_var]
end

--- Get base URL for provider
-- @param provider string: Provider name
-- @return string: Base URL
function M.get_base_url(provider)
    provider = provider or user_config.provider or "openai"
    if provider == "openai" then
        return default_config.api.openai.base_url
    elseif provider == "anthropic" then
        return default_config.api.anthropic.base_url
    end
    return user_config.api_url or default_config.api.compatible.base_url or ""
end

--- Get available models for provider
-- @param provider string: Provider name
-- @return table: List of model names
function M.get_models(provider)
    provider = provider or user_config.provider or "openai"
    if provider == "openai" then
        return default_config.api.openai.models
    elseif provider == "anthropic" then
        return default_config.api.anthropic.models
    end
    return default_config.api.compatible.models
end

--- Get current model
-- @return string: Current model name
function M.get_model()
    return user_config.model or default_config.default_model
end

--- Set current model
-- @param model string: Model name to set
function M.set_model(model)
    user_config.model = model
    vim.notify("AI model set to: " .. model, vim.log.levels.INFO)
end

--- Get current provider
-- @return string: Current provider name
function M.get_provider()
    return user_config.provider or default_config.provider
end

--- Set current provider
-- @param provider string: Provider name
function M.set_provider(provider)
    user_config.provider = provider
    vim.notify("AI provider set to: " .. provider, vim.log.levels.INFO)
end

--- Merge user config with defaults
function M.merge_config()
    user_config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

--- Setup configuration
-- @param config table|nil: User configuration to merge
function M.setup(config)
    user_config = config or {}
    M.merge_config()

    -- Validate API key if provider is set
    local provider = M.get_provider()
    local api_key = M.get_api_key(provider)
    if not api_key then
        vim.notify("AI: No API key set for " .. provider .. ". Set AI_" .. provider:upper() .. "_API_KEY env var.", vim.log.levels.WARN)
    end
end

--- Get full configuration
-- @return table: Complete configuration
function M.get_config()
    return user_config
end

return M
