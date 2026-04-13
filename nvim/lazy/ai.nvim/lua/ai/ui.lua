-- AI Chat UI for PandaVim
-- Right-side chat window with stream processing

local M = {}

local config = require("pandavim.ai.config")
local client = require("pandavim.ai.client")
local skills = require("pandavim.ai.skills")
local diff = require("pandavim.ai.diff")

-- State
local state = {
    chat_window = nil,
    input_window = nil,
    buffer = nil,
    input_buffer = nil,
    is_streaming = false,
    messages = {},  -- Chat history
}

--- Get or create the chat buffer
-- @return number: Buffer number
function M.get_buffer()
    if not state.buffer or not vim.api.nvim_buf_is_valid(state.buffer) then
        state.buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(state.buffer, 'buflisted', false)
        vim.api.nvim_buf_set_option(state.buffer, 'swapfile', false)
        vim.api.nvim_buf_set_option(state.buffer, 'buftype', 'nowrite')
        vim.api.nvim_buf_set_option(state.buffer, 'bufhidden', 'wipe')
    end
    return state.buffer
end

--- Setup highlight groups
function M.setup_highlights()
    -- Chat UI highlights
    vim.api.nvim_set_hl(0, "AiChatUser", { fg = "#60a5fa", bold = true })
    vim.api.nvim_set_hl(0, "AiChatAssistant", { fg = "#34d399", bold = true })
    vim.api.nvim_set_hl(0, "AiChatSystem", { fg = "#f472b6", italic = true })
    vim.api.nvim_set_hl(0, "AiChatMessageUser", { fg = "#e0e7ff" })
    vim.api.nvim_set_hl(0, "AiChatMessageAssistant", { fg = "#d1fae5" })
    vim.api.nvim_set_hl(0, "AiChatPrompt", { fg = "#93c5fd" })
    vim.api.nvim_set_hl(0, "AiChatStatus", { fg = "#a1a1aa", italic = true })
end

--- Create the chat window
-- @param width number: Window width (default 40)
function M.create_chat_window(width)
    width = width or 40

    -- Close existing windows
    M.close_windows()

    local buf = M.get_buffer()
    local win_config = {
        relative = "win",
        width = width,
        height = vim.o.lines - 4,
        col = vim.o.columns - width,
        row = 1,
        style = "minimal",
        border = "rounded",
    }

    state.chat_window = vim.api.nvim_open_win(buf, false, win_config)
    vim.api.nvim_win_set_option(state.chat_window, 'conceallevel', 3)
    vim.api.nvim_win_set_option(state.chat_window, 'list', false)

    -- Add welcome message
    M.print_message("system", "Welcome to PandaVim AI!")
    M.print_message("system", "Type your message and press Enter to send.")
    M.print_message("system", "Use /skills to see available skills.")
end

--- Create the input line
function M.create_input_line()
    local buf = vim.api.nvim_create_buf(false, true)
    state.input_buffer = buf

    local win_config = {
        relative = "win",
        width = 80,
        height = 1,
        col = 0,
        row = vim.o.lines - 1,
        style = "minimal",
        border = "none",
    }

    state.input_window = vim.api.nvim_open_win(buf, false, win_config)
    vim.api.nvim_win_set_option(state.input_window, 'cursorline', true)

    -- Set up insert mode mapping for submit
    local group = vim.api.nvim_create_augroup('AiChatInput', { clear = true })
    vim.api.nvim_create_autocmd('TextChangedI', {
        group = group,
        buffer = buf,
        callback = function()
            vim.api.nvim_buf_set_option(buf, 'modified', false)
        end,
    })

    -- Enter to send, Ctrl-C to cancel
    vim.keymap.set('i', '<CR>', function()
        if state.is_streaming then
            return "<C-C>"
        end
        return M.submit_message()
    end, { buffer = buf, noremap = true, silent = true })

    vim.keymap.set('i', '<C-c>', function()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
        vim.api.nvim_win_set_cursor(state.input_window, { 1, 0 })
    end, { buffer = buf, noremap = true, silent = true })

    -- Set filetype
    vim.api.nvim_buf_set_option(buf, 'filetype', 'ai-chat')
end

--- Print a message to the chat window
-- @param role string: 'user', 'assistant', or 'system'
-- @param content string: Message content
function M.print_message(role, content)
    local buf = M.get_buffer()
    local lines = vim.split(content, "\n", { trimempty = false })

    local timestamp = os.date("%H:%M:%S")
    local prefix
    local hl_group

    if role == "user" then
        prefix = "[User] " .. timestamp .. " "
        hl_group = "AiChatMessageUser"
    elseif role == "assistant" then
        prefix = "[AI] " .. timestamp .. " "
        hl_group = "AiChatMessageAssistant"
    else
        prefix = "[System] " .. timestamp .. " "
        hl_group = "AiChatMessageSystem"
    end

    -- Add prefix line
    table.insert(lines, 1, prefix)

    -- Apply highlights
    local start_line = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

    -- Highlight the prefix
    local end_line = start_line + #lines
    local hl_id = vim.api.nvim_get_hl_id_by_name(hl_group)
    if hl_id ~= 0 then
        vim.api.nvim_buf_add_highlight(buf, hl_id, 0, start_line, 0, #prefix)
    end

    -- Scroll to bottom
    vim.api.nvim_win_set_cursor(state.chat_window, { vim.api.nvim_buf_line_count(buf), 0 })
end

--- Submit message from input
-- @return string: The submitted message
function M.submit_message()
    local buf = state.input_buffer
    if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return ""
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local message = table.concat(lines, "\n")

    if message == "" or message:match("^%s*$") then
        return ""
    end

    -- Clear input
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })

    -- Process message
    M.process_user_message(message)

    return message
end

--- Process user message (handles commands and normal messages)
-- @param message string: User message
function M.process_user_message(message)
    -- Handle commands
    if message:sub(1, 1) == "/" then
        M.process_command(message)
        return
    end

    -- Add user message to chat
    table.insert(state.messages, { role = "user", content = message })
    M.print_message("user", message)

    -- Get response
    M.get_ai_response()
end

--- Process slash commands
-- @param command string: Full command including /
function M.process_command(command)
    local parts = vim.split(command:sub(2), "%s+", { trimempty = true })
    local cmd = parts[1]
    local args = table.concat(parts, " ", 2)

    if cmd == "skills" then
        local skill_list = skills.list_skills()
        M.print_message("system", "Available skills:")
        for _, skill in ipairs(skill_list) do
            M.print_message("system", "  " .. skill)
        end
    elseif cmd == "clear" then
        state.messages = {}
        local buf = M.get_buffer()
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
        M.print_message("system", "Chat history cleared.")
    elseif cmd == "model" then
        if args ~= "" then
            config.set_model(args)
            M.print_message("system", "Model set to: " .. args)
        else
            M.print_message("system", "Current model: " .. config.get_model())
        end
    elseif cmd == "provider" then
        if args ~= "" then
            config.set_provider(args)
            M.print_message("system", "Provider set to: " .. args)
        else
            M.print_message("system", "Current provider: " .. config.get_provider())
        end
    elseif cmd == "help" then
        M.print_message("system", "Commands:")
        M.print_message("system", "  /skills - List available skills")
        M.print_message("system", "  /clear - Clear chat history")
        M.print_message("system", "  /model <name> - Set model")
        M.print_message("system", "  /provider <name> - Set provider")
        M.print_message("system", "  /help - Show this help")
    else
        M.print_message("system", "Unknown command: " .. cmd .. ". Type /help for commands.")
    end
end

--- Get AI response with streaming
function M.get_ai_response()
    if state.is_streaming then
        return
    end

    state.is_streaming = true
    M.print_message("system", "Thinking...")

    -- Prepare messages for API
    local api_messages = {}
    for _, msg in ipairs(state.messages) do
        table.insert(api_messages, {
            role = msg.role,
            content = msg.content,
        })
    end

    -- Stream response
    local current_response = ""
    client.chat_completion(
        api_messages,
        { model = config.get_model() },
        function(chunk)
            -- Append chunk to current response
            current_response = current_response .. chunk

            -- Update the assistant's message in real-time
            local buf = M.get_buffer()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

            -- Find the last assistant message and update it
            for i = #lines, 1, -1 do
                if lines[i]:match("^%[AI%]") then
                    -- Get the content line after the timestamp
                    if i + 1 <= #lines then
                        local content_line = lines[i + 1]
                        local prefix_len = #("[AI] " .. os.date("%H:%M:%S") .. " ")
                        local existing = content_line:sub(prefix_len + 1)
                        local new_content = existing .. chunk

                        vim.api.nvim_buf_set_lines(buf, i + 1, i + 2, false, { new_content })
                        vim.api.nvim_win_set_cursor(state.chat_window, { vim.api.nvim_buf_line_count(buf), 0 })
                    end
                    break
                end
            end
        end,
        function()
            -- Complete
            state.is_streaming = false
            table.insert(state.messages, { role = "assistant", content = current_response })
        end,
        function(err)
            state.is_streaming = false
            M.print_message("system", "Error: " .. err)
        end
    )
end

--- Close all AI windows
function M.close_windows()
    if state.chat_window and vim.api.nvim_win_is_valid(state.chat_window) then
        vim.api.nvim_win_close(state.chat_window, true)
        state.chat_window = nil
    end

    if state.input_window and vim.api.nvim_win_is_valid(state.input_window) then
        vim.api.nvim_win_close(state.input_window, true)
        state.input_window = nil
    end

    if state.buffer and state.buffer ~= vim.api.nvim_get_current_buf() then
        vim.api.nvim_buf_delete(state.buffer, { force = true })
        state.buffer = nil
    end
end

--- Toggle chat window visibility
function M.toggle()
    if state.chat_window and vim.api.nvim_win_is_valid(state.chat_window) then
        M.close_windows()
    else
        M.create_chat_window()
        M.create_input_line()
    end
end

--- Open chat window
function M.open()
    if not state.chat_window or not vim.api.nvim_win_is_valid(state.chat_window) then
        M.create_chat_window()
        M.create_input_line()
    end
    vim.api.nvim_set_current_win(state.input_window)
end

--- Close chat window
function M.close()
    M.close_windows()
end

--- Setup the AI UI module
function M.setup()
    M.setup_highlights()
    vim.api.nvim_create_user_command("AIOpen", function()
        M.open()
    end, {})
    vim.api.nvim_create_user_command("AIClose", function()
        M.close()
    end, {})
    vim.api.nvim_create_user_command("AIToggle", function()
        M.toggle()
    end, {})
end

return M
