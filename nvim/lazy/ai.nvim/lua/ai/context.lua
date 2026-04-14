-- File Context System for PandaVim AI
-- Manage files to include in chat context

local M = {}

-- State
local state = {
    selected_files = {},  -- Buffer numbers to include in context
}

--- Get all open buffers
-- @return table: List of buffers with info
function M.get_buffers()
    local buffers = {}
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
            local name = vim.api.nvim_buf_get_name(bufnr)
            if name ~= "" then
                local filename = vim.fn.fnamemodify(name, ":~")
                table.insert(buffers, {
                    bufnr = bufnr,
                    filename = filename,
                    name = name,
                    relative = vim.fn.fnamemodify(name, ":.")
                })
            end
        end
    end
    return buffers
end

--- Toggle file context for a buffer
-- @param bufnr number: Buffer number
function M.toggle_file_context(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local found = false
    local new_selection = {}

    for _, selected in ipairs(state.selected_files) do
        if selected == bufnr then
            found = true
        else
            table.insert(new_selection, selected)
        end
    end

    if not found then
        table.insert(new_selection, bufnr)
        vim.notify("Added to context: " .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.INFO)
    else
        vim.notify("Removed from context: " .. vim.api.nvim_buf_get_name(bufnr), vim.log.levels.INFO)
    end

    state.selected_files = new_selection
end

--- Check if buffer is in context
-- @param bufnr number: Buffer number
-- @return boolean: true if in context
function M.is_in_context(bufnr)
    for _, selected in ipairs(state.selected_files) do
        if selected == bufnr then
            return true
        end
    end
    return false
end

--- Get context as formatted string for AI
-- @return string: Formatted context
function M.get_context_string()
    if #state.selected_files == 0 then
        return ""
    end

    local context = {}
    table.insert(context, "--- File Context ---")

    for _, bufnr in ipairs(state.selected_files) do
        local name = vim.api.nvim_buf_get_name(bufnr)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local content = table.concat(lines, "\n")

        table.insert(context, string.format("File: %s", name))
        table.insert(context, string.format("```", name))
        table.insert(context, content)
        table.insert(context, "```")
        table.insert(context, "")
    end

    return table.concat(context, "\n")
end

--- Clear all selected files
function M.clear()
    state.selected_files = {}
    vim.notify("Context cleared", vim.log.levels.INFO)
end

--- Get selected files
-- @return table: List of selected buffer numbers
function M.get_selected()
    return state.selected_files
end

--- Count selected files
-- @return number: Number of selected files
function M.count()
    return #state.selected_files
end

return M
