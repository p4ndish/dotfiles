-- AI Chat UI for PandaVim
-- Full-height sidebar chat interface like Cursor/Windsurf

local M = {}

local config = require("ai.config")
local client = require("ai.client")
local skills = require("ai.skills")
local context = require("ai.context")
local diff = require("ai.diff")

-- State
local state = {
    chat_window = nil,
    input_window = nil,
    buffer = nil,
    input_buffer = nil,
    is_streaming = false,
    messages = {},  -- Chat history
    editor_win = nil,  -- Track editor window for focus
    header_lines = 10,  -- Lines for header/info area
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
        vim.api.nvim_buf_set_option(state.buffer, 'filetype', 'ai-chat')
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
    vim.api.nvim_set_hl(0, "AiChatHeader", { fg = "#f59e0b", bold = true })
    vim.api.nvim_set_hl(0, "AiChatFile", { fg = "#8b5cf6" })
end

--- Update header with model and file info
function M.update_header()
    if not state.chat_window or not vim.api.nvim_win_is_valid(state.chat_window) then
        return
    end

    local buf = M.get_buffer()
    local current_model = config.get_model()
    local file_count = context.count()
    local provider = config.get_provider()

    local header_lines = {
        string.format(" AI Chat [Model: %s] [Provider: %s] [Files: %d] ", current_model, provider, file_count),
        "────────────────────────────────────────────────────────────────────────────",
        " [File Context] [Skills] /help for commands",
        "",
    }

    -- Set header lines at top of buffer
    vim.api.nvim_buf_set_lines(buf, 0, #header_lines, false, header_lines)

    -- Apply header highlight
    local header_id = vim.api.nvim_get_hl_id_by_name("AiChatHeader")
    if header_id ~= 0 then
        vim.api.nvim_buf_add_highlight(buf, header_id, 0, 0, 0, -1)
    end
end

--- Create the full-height chat window
function M.create_chat_window()
    -- Close existing windows
    M.close_windows()

    -- Save editor window
    state.editor_win = vim.api.nvim_get_current_win()

    local buf = M.get_buffer()
    local width = math.floor(vim.o.columns * 0.3)  -- 30% of screen width

    local win_config = {
        relative = "editor",
        width = width,
        height = math.floor(vim.o.lines),
        col = vim.o.columns - width,
        row = 0,  -- Start at top for full height
        style = "minimal",
        border = "rounded",
    }

    state.chat_window = vim.api.nvim_open_win(buf, false, win_config)
    vim.api.nvim_win_set_option(state.chat_window, 'conceallevel', 3)
    vim.api.nvim_win_set_option(state.chat_window, 'list', false)

    -- Setup buffer options
    vim.api.nvim_buf_set_option(buf, 'scrollbind', false)
    vim.api.nvim_buf_set_option(buf, 'cursorbind', false)

    -- Update header
    M.update_header()

    -- Add welcome message after header
    local welcome_lines = {
        "",
        "Welcome to PandaVim AI!",
        "",
        "Type your message and press Enter to send.",
        "Use /help to see available commands.",
        "",
    }

    local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, line in ipairs(welcome_lines) do
        table.insert(current_lines, line)
    end
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, welcome_lines)

    -- Add model info line
    local model_lines = {
        "Current model: " .. config.get_model(),
        "",
    }
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, model_lines)

    -- Scroll to bottom
    vim.api.nvim_win_set_cursor(state.chat_window, { vim.api.nvim_buf_line_count(buf), 0 })
end

--- Create the input area at bottom of chat window
function M.create_input_area()
    local buf = vim.api.nvim_create_buf(false, true)
    state.input_buffer = buf

    local chat_width = math.floor(vim.o.columns * 0.3)
    local win_config = {
        relative = "editor",
        width = chat_width,
        height = 3,  -- Input area height
        col = vim.o.columns - chat_width,
        row = vim.o.lines - 3,
        style = "minimal",
        border = "rounded",
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
    vim.api.nvim_buf_set_option(buf, 'filetype', 'ai-chat-input')
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
        prefix = "👤 You [" .. timestamp .. "] "
        hl_group = "AiChatMessageUser"
    elseif role == "assistant" then
        prefix = "🤖 AI [" .. timestamp .. "] "
        hl_group = "AiChatMessageAssistant"
    else
        prefix = "ℹ️  System [" .. timestamp .. "] "
        hl_group = "AiChatSystem"
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

    -- Update header
    M.update_header()

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

    -- Add file context if any files are selected
    local context_string = context.get_context_string()
    local full_message = message
    if context_string ~= "" then
        full_message = context_string .. "\n\n---\n\n" .. message
    end

    -- Add user message to chat
    table.insert(state.messages, { role = "user", content = full_message })
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
        M.create_chat_window()
        M.create_input_area()
        M.print_message("system", "Chat history cleared.")
    elseif cmd == "help" then
        M.print_message("system", "Commands:")
        M.print_message("system", "  /skills - List available skills")
        M.print_message("system", "  /clear - Clear chat history")
        M.print_message("system", "  /model <name> - Set model")
        M.print_message("system", "  /provider <name> - Set provider")
        M.print_message("system", "  /help - Show this help")
        M.print_message("system", "  /files - Show selected files")
        M.print_message("system", "  /addfile <bufnr> - Add file to context")
        M.print_message("system", "  /removefile <bufnr> - Remove file from context")
    elseif cmd == "model" then
        if args ~= "" then
            config.set_model(args)
            M.update_header()
            M.print_message("system", "Model set to: " .. args)
        else
            M.print_message("system", "Current model: " .. config.get_model())
        end
    elseif cmd == "provider" then
        if args ~= "" then
            config.set_provider(args)
            M.update_header()
            M.print_message("system", "Provider set to: " .. args)
        else
            M.print_message("system", "Current provider: " .. config.get_provider())
        end
    elseif cmd == "files" then
        local files = context.get_selected()
        if #files == 0 then
            M.print_message("system", "No files in context")
        else
            M.print_message("system", "Files in context:")
            for _, bufnr in ipairs(files) do
                M.print_message("system", "  - " .. vim.api.nvim_buf_get_name(bufnr))
            end
        end
    elseif cmd == "addfile" then
        local bufnr = tonumber(args)
        if bufnr then
            context.toggle_file_context(bufnr)
            M.update_header()
        else
            M.print_message("system", "Usage: /addfile <bufnr>")
        end
    elseif cmd == "removefile" then
        local bufnr = tonumber(args)
        if bufnr then
            context.toggle_file_context(bufnr)
            M.update_header()
        else
            M.print_message("system", "Usage: /removefile <bufnr>")
        end
    elseif cmd == "focus" then
        if args == "editor" then
            if state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
                vim.api.nvim_set_current_win(state.editor_win)
            end
        elseif args == "chat" then
            if state.input_window and vim.api.nvim_win_is_valid(state.input_window) then
                vim.api.nvim_set_current_win(state.input_window)
            end
        end
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

    -- Don't delete buffer - just clear it for reuse
    if state.buffer then
        vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, {})
        state.buffer = nil
    end
end

--- Toggle chat window visibility
function M.toggle()
    if state.chat_window and vim.api.nvim_win_is_valid(state.chat_window) then
        M.close_windows()
    else
        M.create_chat_window()
        M.create_input_area()
    end
end

--- Open chat window
function M.open()
    if not state.chat_window or not vim.api.nvim_win_is_valid(state.chat_window) then
        M.create_chat_window()
        M.create_input_area()
    end
    -- Focus input area
    if state.input_window and vim.api.nvim_win_is_valid(state.input_window) then
        vim.api.nvim_set_current_win(state.input_window)
    end
end

--- Close chat window
function M.close()
    M.close_windows()
end

--- Focus editor window
function M.focus_editor()
    if state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
        vim.api.nvim_set_current_win(state.editor_win)
    end
end

--- Focus chat window
function M.focus_chat()
    if state.input_window and vim.api.nvim_win_is_valid(state.input_window) then
        vim.api.nvim_set_current_win(state.input_window)
    end
end

--- Setup the AI UI module
function M.setup()
    M.setup_highlights()

    -- Create user commands
    vim.api.nvim_create_user_command("AIOpen", function()
        M.open()
    end, {})

    vim.api.nvim_create_user_command("AIClose", function()
        M.close()
    end, {})

    vim.api.nvim_create_user_command("AIToggle", function()
        M.toggle()
    end, {})

    vim.api.nvim_create_user_command("AIFocusEditor", function()
        M.focus_editor()
    end, {})

    vim.api.nvim_create_user_command("AIFocusChat", function()
        M.focus_chat()
    end, {})

    vim.api.nvim_create_user_command("AIClear", function()
        M.process_command("/clear")
    end, {})

    vim.api.nvim_create_user_command("AISkills", function()
        M.process_command("/skills")
    end, {})
end

return M
