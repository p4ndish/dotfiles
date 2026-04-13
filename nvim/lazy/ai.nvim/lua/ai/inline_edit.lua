-- Inline Edit for PandaVim AI
-- Edit selected lines or current line with AI

local M = {}

local config = require("pandavim.ai.config")
local client = require("pandavim.ai.client")
local skills = require("pandavim.ai.skills")
local diff = require("pandavim.ai.diff")

--- Get current selection or current line
-- @return string: Selected content
-- @return number: Start line (1-indexed)
-- @return number: End line (1-indexed)
function M.get_selection()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Check if in visual mode
    local mode = vim.fn.mode()
    if mode:match("[vV\x16]") then
        -- Visual mode
        local start = vim.fn.line("'<")
        local end_ = vim.fn.line("'>")
        local lines = vim.api.nvim_buf_get_lines(bufnr, start - 1, end_, false)
        return table.concat(lines, "\n"), start, end_
    else
        -- Normal mode - get current line
        local lnum = vim.fn.line(".")
        local line = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
        return line or "", lnum, lnum
    end
end

--- Show diff preview
-- @param original string: Original content
-- @param modified string: Modified content
-- @return boolean: true if user confirmed
function M.show_diff_preview(original, modified)
    -- Create a preview buffer
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(bufnr, 'swapfile', false)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')

    local lines = {}
    table.insert(lines, "```diff")
    table.insert(lines, "-- Original")
    table.insert(lines, "++ Modified")
    table.insert(lines, "```")
    table.insert(lines, "")

    -- Simple diff
    local orig_lines = vim.split(original, "\n", { trimempty = false })
    local mod_lines = vim.split(modified, "\n", { trimempty = false })

    local i, j = 1, 1
    while i <= #orig_lines or j <= #mod_lines do
        if i <= #orig_lines and j <= #mod_lines and orig_lines[i] == mod_lines[j] then
            table.insert(lines, " " .. orig_lines[i])
            i = i + 1
            j = j + 1
        elseif j <= #mod_lines and (i > #orig_lines or orig_lines[i] ~= mod_lines[j]) then
            table.insert(lines, "+" .. mod_lines[j])
            j = j + 1
        elseif i <= #orig_lines then
            table.insert(lines, "-" .. orig_lines[i])
            i = i + 1
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    diff.apply_highlights(bufnr)

    -- Show in preview window
    vim.cmd("pedit +set\\buftype=nofile AIEditPreview")
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_buf(bufnr)

    -- Ask for confirmation
    vim.api.nvim_echo({
        { "Apply these changes? ", "Question" },
        { "(y/n) ", "Question" },
    }, true, {})

    local response = vim.fn.getchar()
    vim.api.nvim_win_close(winnr, true)
    vim.api.nvim_buf_delete(bufnr, { force = true })

    return response == string.byte("y") or response == string.byte("Y")
end

--- Apply changes to buffer
-- @param bufnr number: Buffer number
-- @param start_line number: Start line (1-indexed)
-- @param end_line number: End line (1-indexed)
-- @param content string: New content
function M.apply_changes(bufnr, start_line, end_line, content)
    local new_lines = vim.split(content, "\n", { trimempty = false })
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)

    -- Position cursor at start of modified section
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })

    vim.notify("Changes applied!", vim.log.levels.INFO)
end

--- Process inline edit
-- @param prompt string: Edit prompt
function M.edit(prompt)
    local content, start_line, end_line = M.get_selection()
    if content == "" then
        vim.notify("No content to edit", vim.log.levels.WARN)
        return
    end

    -- Build full prompt with skill
    local full_prompt = skills.build_prompt("fix", content)
    if prompt and prompt ~= "" then
        full_prompt = full_prompt .. "\n\nAdditional instructions: " .. prompt
    end

    -- Show we're working
    vim.notify("AI editing...", vim.log.levels.INFO)

    -- Get AI response
    local response = ""
    local success, err = pcall(function()
        client.chat_completion(
            { { role = "user", content = full_prompt } },
            { model = config.get_model() },
            function(chunk)
                response = response .. chunk
            end
        )
    end)

    if not success or err then
        vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    if response == "" then
        vim.notify("No changes from AI", vim.log.levels.WARN)
        return
    end

    -- Show diff preview
    if M.show_diff_preview(content, response) then
        local bufnr = vim.api.nvim_get_current_buf()
        M.apply_changes(bufnr, start_line, end_line, response)
    else
        vim.notify("Changes cancelled", vim.log.levels.INFO)
    end
end

--- Command handler
-- @param args string: Command arguments
function M.handle_command(args)
    M.edit(args)
end

--- Setup keymaps and commands
function M.setup()
    vim.api.nvim_create_user_command("AIEdit", function(args)
        M.handle_command(args.args)
    end, { nargs = "*" })

    -- Visual mode mapping
    vim.keymap.set("v", "<leader>ae", function()
        local content, start_line, end_line = M.get_selection()
        if content == "" then
            vim.notify("No selection", vim.log.levels.WARN)
            return
        end
        -- Store selection for command
        vim.cmd("normal! gv")
        M.edit("")
    end, { noremap = true, silent = true, desc = "AI Edit selection" })

    -- Normal mode mapping
    vim.keymap.set("n", "<leader>ae", function()
        M.edit("")
    end, { noremap = true, silent = true, desc = "AI Edit current line" })
end

return M
