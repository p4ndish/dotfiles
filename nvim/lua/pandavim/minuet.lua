local M = {}

local function openai_compatible(name, api_key_env, endpoint, model)
    return {
        end_point = endpoint,
        api_key = api_key_env,
        name = name,
        model = model,
        optional = {
            max_tokens = 56,
            top_p = 0.9,
        },
    }
end

local function openai_fim_compatible(name, api_key_env, endpoint, model)
    return {
        end_point = endpoint,
        api_key = api_key_env,
        name = name,
        model = model,
        optional = {
            max_tokens = 56,
            top_p = 0.9,
        },
    }
end

function M.setup()
    local ok, minuet = pcall(require, 'minuet')
    if not ok then
        vim.notify('Minuet not available', vim.log.levels.WARN)
        return
    end

    minuet.setup({
        provider = 'openai_compatible',
        request_timeout = 2.5,
        throttle = 1500,
        debounce = 600,
        n_completions = 1,
        provider_options = {
            openai_compatible = openai_compatible(
                'OpenAI',
                'OPENAI_API_KEY',
                'https://api.openai.com/v1/chat/completions',
                'gpt-4o-mini'
            ),
            openai_fim_compatible = openai_fim_compatible(
                'deepseek',
                'DEEPSEEK_API_KEY',
                'https://api.deepseek.com/beta/completions',
                'deepseek-chat'
            ),
        },
    })

    vim.api.nvim_create_user_command('MinuetOpenAI', function()
        minuet.change_provider('openai_compatible')
    end, { desc = 'Switch Minuet provider to OpenAI-compatible' })

    vim.api.nvim_create_user_command('MinuetDeepSeek', function()
        minuet.change_provider('openai_fim_compatible')
    end, { desc = 'Switch Minuet provider to DeepSeek FIM' })

    vim.keymap.set('n', '<leader>ao', '<cmd>MinuetOpenAI<CR>', { noremap = true, silent = true, desc = 'AI: OpenAI' })
    vim.keymap.set('n', '<leader>ad', '<cmd>MinuetDeepSeek<CR>', { noremap = true, silent = true, desc = 'AI: DeepSeek' })
end

return M
