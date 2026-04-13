-- Diff Rendering for PandaVim AI
-- Git-style diff display with colors for additions/deletions

local M = {}

-- Diff highlight groups
local HIGHLIGHTS = {
    add = "DiffAdd",    -- Green for additions
    delete = "DiffDelete", -- Red for deletions
    change = "DiffChange", -- Yellow for modifications
    text = "DiffText",  -- Blue for context
}

--- Setup highlight groups
function M.setup_highlights()
    -- DiffAdd - Green background for additions
    vim.api.nvim_set_hl(0, HIGHLIGHTS.add, {
        bg = "#1e3a2a",
        fg = "#86efac",
        bold = true,
    })

    -- DiffDelete - Red background for deletions
    vim.api.nvim_set_hl(0, HIGHLIGHTS.delete, {
        bg = "#3a1e1e",
        fg = "#fca5a5",
        bold = true,
    })

    -- DiffChange - Yellow background for modifications
    vim.api.nvim_set_hl(0, HIGHLIGHTS.change, {
        bg = "#3a3a1e",
        fg = "#fde047",
        bold = true,
    })

    -- DiffText - Blue for changed text
    vim.api.nvim_set_hl(0, HIGHLIGHTS.text, {
        fg = "#60a5fa",
        bold = true,
    })
end

--- Parse diff content and return marked lines
-- @param diff string: Diff content
-- @return table: Array of {line, type} where type is 'add', 'delete', 'context'
function M.parse_diff(diff)
    local lines = vim.split(diff, "\n", { trimempty = true })
    local result = {}

    for _, line in ipairs(lines) do
        if line:sub(1, 1) == "+" then
            table.insert(result, { line = line, type = "add" })
        elseif line:sub(1, 1) == "-" then
            table.insert(result, { line = line, type = "delete" })
        elseif line:sub(1, 1) == "\\" then
            -- Skip "\ No newline" lines
        elseif line:sub(1, 2) == "@@" then
            -- Skip diff headers
            table.insert(result, { line = line, type = "context" })
        else
            -- Context lines (unchanged)
            table.insert(result, { line = line, type = "context" })
        end
    end

    return result
end

--- Create diff buffer content
-- @param original string: Original content
-- @param modified string: Modified content
-- @return table: Buffer lines with diff markers
function M.create_diff_buffer(original, modified)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local lines = {}

    -- Add header
    table.insert(lines, "```diff")
    table.insert(lines, "-- Original")
    table.insert(lines, "++ Modified")
    table.insert(lines, "```")
    table.insert(lines, "")

    -- Simple line-by-line comparison
    local orig_lines = vim.split(original, "\n", { trimempty = false })
    local mod_lines = vim.split(modified, "\n", { trimempty = false })

    local i, j = 1, 1
    while i <= #orig_lines or j <= #mod_lines do
        if i <= #orig_lines and j <= #mod_lines and orig_lines[i] == mod_lines[j] then
            -- Unchanged line
            table.insert(lines, " " .. orig_lines[i])
            i = i + 1
            j = j + 1
        elseif j <= #mod_lines and (i > #orig_lines or orig_lines[i] ~= mod_lines[j]) then
            -- Added line
            table.insert(lines, "+" .. mod_lines[j])
            j = j + 1
        elseif i <= #orig_lines then
            -- Deleted line
            table.insert(lines, "-" .. orig_lines[i])
            i = i + 1
        end
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return bufnr
end

--- Highlight a diff line based on type
-- @param bufnr number: Buffer number
-- @param line number: Line number (1-indexed)
-- @param type string: 'add', 'delete', or 'context'
function M.highlight_line(bufnr, line, type)
    local group = HIGHLIGHTS[type] or HIGHLIGHTS.text
    local highlight_id = vim.api.nvim_get_hl_id_by_name(group)

    if highlight_id ~= 0 then
        vim.api.nvim_buf_add_highlight(bufnr, highlight_id, 0, line - 1, line - 1, -1)
    end
end

--- Apply diff highlighting to buffer
-- @param bufnr number: Buffer number
function M.apply_highlights(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    for i, line in ipairs(lines) do
        if line:sub(1, 1) == "+" then
            M.highlight_line(bufnr, i, "add")
        elseif line:sub(1, 1) == "-" then
            M.highlight_line(bufnr, i, "delete")
        end
    end
end

--- Render inline diff in current buffer
-- @param bufnr number: Target buffer
-- @param changes table: Array of {line, type, content}
function M.render_inline_diff(bufnr, changes)
    -- Clear previous diagnostics
    vim.diagnostic.reset(bufnr, "ai_diff")

    local diagnostics = {}
    local current_line = 0

    for _, change in ipairs(changes) do
        if change.type == "add" then
            -- Add diagnostic for new content
            table.insert(diagnostics, {
               lnum = current_line,
                col = 0,
                message = "+ " .. (change.content or ""),
                severity = vim.diagnostic.severity.HINT,
                source = "AI",
            })
        elseif change.type == "delete" then
            -- Mark line for deletion
            table.insert(diagnostics, {
               lnum = current_line,
                col = 0,
                message = "- " .. (change.content or ""),
                severity = vim.diagnostic.severity.WARN,
                source = "AI",
            })
        elseif change.type == "context" then
            current_line = current_line + 1
        end
    end

    vim.diagnostic.set(0, bufnr, diagnostics, {
        virtual_text = {
            format = function(diag)
                if diag.message:sub(1, 1) == "+" then
                    return { { diag.message, "DiffAdd" } }
                elseif diag.message:sub(1, 1) == "-" then
                    return { { diag.message, "DiffDelete" } }
                end
                return diag.message
            end,
            spacing = 2,
            prefix = "●",
        },
    })
end

return M
