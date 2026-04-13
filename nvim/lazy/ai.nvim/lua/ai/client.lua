-- AI API Client for PandaVim
-- Supports OpenAI, Anthropic Claude, and OpenAI-compatible endpoints

local M = {}
local config = require("pandavim.ai.config")

--- Make HTTP request to AI API
-- @param endpoint string: API endpoint path
-- @param method string: HTTP method (GET, POST)
-- @param body table: Request body
-- @param callback function: Callback with (response, error)
function M.request(endpoint, method, body, callback)
    local provider = config.get_provider()
    local api_key = config.get_api_key(provider)
    local base_url = config.get_base_url(provider)

    if not api_key then
        callback(nil, "No API key configured for provider: " .. provider)
        return
    end

    if not base_url or base_url == "" then
        callback(nil, "No base URL configured for provider: " .. provider)
        return
    end

    local url = base_url .. endpoint
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. api_key,
    }

    -- Add anthropic-specific headers
    if provider == "anthropic" then
        headers["x-api-key"] = api_key
        headers["anthropic-version"] = "2023-06-01"
        headers["User-Agent"] = "pandavim-ai/1.0"
    end

    -- Encode body as JSON
    local body_json = vim.json.encode(body)

    -- Use vim.system for async HTTP (Neovim >= 0.10)
    if vim.system then
        local proc = vim.system({
            "curl",
            "-s",
            "-X", method,
            "-H", "Content-Type: application/json",
            "-H", "Authorization: Bearer " .. api_key,
            "-d", body_json,
            url,
        }, {}, function()
            -- Callback handled in async wrapper
        end)

        -- Simple async using job
        local job_id = vim.fn.jobstart({
            "curl",
            "-s",
            "-X", method,
            "-H", "Content-Type: application/json",
            "-H", "Authorization: Bearer " .. api_key,
            "-d", body_json,
            url,
        }, {
            on_stdout = function(_, data)
                if data and #data > 0 then
                    local response_body = table.concat(data, "\n")
                    callback({ body = response_body }, nil)
                end
            end,
            on_exit = function(_, code)
                if code ~= 0 then
                    callback(nil, "HTTP request failed with code: " .. code)
                end
            end,
        })
    else
        -- Fallback: use system() sync (not ideal but works)
        local cmd = string.format(
            'curl -s -X %s -H "Content-Type: application/json" -H "Authorization: Bearer %s" -d %s %s',
            method,
            api_key,
            vim.fn.shellescape(body_json),
            vim.fn.shellescape(url)
        )

        local output = vim.fn.system(cmd)
        if vim.v.shell_error == 0 then
            callback({ body = output }, nil)
        else
            callback(nil, "HTTP request failed: " .. output)
        end
    end
end

--- Chat completion with streaming
-- @param messages table: Array of messages [{role, content}, ...]
-- @param options table: Optional settings (model, temperature, max_tokens)
-- @param on_chunk function: Callback for each response chunk
-- @param on_complete function: Callback when complete
-- @param on_error function: Callback on error
function M.chat_completion(messages, options, on_chunk, on_complete, on_error)
    local model = options and options.model or config.get_model()
    local temperature = options and options.temperature or config.get_config().temperature
    local max_tokens = options and options.max_tokens or config.get_config().max_tokens

    local provider = config.get_provider()
    local body = {
        model = model,
        messages = messages,
        temperature = temperature,
        max_tokens = max_tokens,
        stream = true,  -- Enable streaming
    }

    local endpoint
    if provider == "anthropic" then
        -- Anthropic uses different format
        body.max_tokens = max_tokens
        endpoint = "/messages"
    else
        -- OpenAI compatible
        endpoint = "/chat/completions"
    end

    M.request(endpoint, "POST", body, function(response, err)
        if err then
            if on_error then
                on_error(err)
            end
            return
        end

        if not response or not response.body then
            if on_error then
                on_error("Empty response from API")
            end
            return
        end

        -- Parse and process streaming response
        local lines = vim.split(response.body, "\n", { trimempty = true })

        for _, line in ipairs(lines) do
            if line:match("^data:") then
                local data = line:gsub("^data:%s*", "")
                if data ~= "[DONE]" then
                    local success, parsed = pcall(vim.json.decode, data)
                    if success and parsed then
                        local content = ""
                        if provider == "anthropic" then
                            content = parsed.delta and parsed.delta.text or ""
                        else
                            content = parsed.choices and parsed.choices[1] and parsed.choices[1].delta and parsed.choices[1].delta.content or ""
                        end

                        if content ~= "" and on_chunk then
                            on_chunk(content)
                        end
                    end
                else
                    -- Stream complete
                    if on_complete then
                        on_complete()
                    end
                end
            end
        end
    end)
end

--- Generate image (optional feature)
-- @param prompt string: Image description
-- @param callback function: Callback with (image_url, error)
function M.generate_image(prompt, callback)
    local model = config.get_config().api.openai.models.gpt4o
    local body = {
        model = model,
        prompt = prompt,
        n = 1,
        size = "1024x1024",
    }

    M.request("/images/generations", "POST", body, function(response, err)
        if err then
            callback(nil, err)
            return
        end

        local success, parsed = pcall(vim.json.decode, response.body)
        if success and parsed and parsed.data and #parsed.data > 0 then
            callback(parsed.data[1].url, nil)
        else
            callback(nil, "Failed to generate image")
        end
    end)
end

--- Get models list from API
-- @param callback function: Callback with (models, error)
function M.get_models_list(callback)
    local provider = config.get_provider()
    local endpoint

    if provider == "anthropic" then
        endpoint = "/models"
    else
        endpoint = "/models"
    end

    M.request(endpoint, "GET", {}, function(response, err)
        if err then
            callback(nil, err)
            return
        end

        local success, parsed = pcall(vim.json.decode, response.body)
        if success then
            if provider == "anthropic" then
                local models = {}
                for _, model in ipairs(parsed.data or {}) do
                    table.insert(models, model.id)
                end
                callback(models, nil)
            else
                local models = {}
                for _, model in ipairs(parsed.data or {}) do
                    table.insert(models, model.id)
                end
                callback(models, nil)
            end
        else
            callback(nil, "Failed to parse models list")
        end
    end)
end

return M
