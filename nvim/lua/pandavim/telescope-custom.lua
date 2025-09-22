-- Custom Telescope modifications and safe previewing functions
local M = {}

-- Define custom view functions that don't depend on preview functionality
function M.safe_open_file(prompt_bufnr, mode)
    local action_state = require("telescope.actions.state")
    local actions = require("telescope.actions")
    
    -- Get the current picker and selection
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    
    if not selection then
        vim.notify("No file selected", vim.log.levels.WARN)
        return
    end
    
    -- Close Telescope before trying to open the file
    actions.close(prompt_bufnr)
    
    -- Wait a bit for Telescope to clean up
    vim.defer_fn(function()
        local file_path = selection.path or selection.filename or selection[1]
        
        -- If we don't have a path, do nothing
        if not file_path then
            vim.notify("Invalid file selection", vim.log.levels.ERROR)
            return
        end
        
        -- Open the file based on the requested mode
        if mode == "edit" then
            vim.cmd("edit " .. vim.fn.fnameescape(file_path))
        elseif mode == "split" then
            vim.cmd("split " .. vim.fn.fnameescape(file_path))
        elseif mode == "vsplit" then
            vim.cmd("vsplit " .. vim.fn.fnameescape(file_path))
        elseif mode == "tab" then
            vim.cmd("tabedit " .. vim.fn.fnameescape(file_path))
        end
    end, 10) -- 10ms delay to ensure Telescope has time to close
end

-- Setup custom keymaps for all Telescope pickers
function M.setup_custom_mappings()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    
    -- Create custom actions
    local custom_actions = {}
    
    -- Safe file opening actions
    custom_actions.safe_edit = function(prompt_bufnr)
        M.safe_open_file(prompt_bufnr, "edit")
    end
    
    custom_actions.safe_split = function(prompt_bufnr)
        M.safe_open_file(prompt_bufnr, "split")
    end
    
    custom_actions.safe_vsplit = function(prompt_bufnr)
        M.safe_open_file(prompt_bufnr, "vsplit")
    end
    
    custom_actions.safe_tab = function(prompt_bufnr)
        M.safe_open_file(prompt_bufnr, "tab")
    end
    
    -- Register our custom actions
    return custom_actions
end

return M 