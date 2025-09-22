-- Custom patch for Telescope's buffer_previewer.lua
local M = {}

function M.apply_patches()
    -- Get the actual module path
    local buffer_previewer_path = package.loaded["telescope.previewers.buffer_previewer"]
    local ok, previewers = pcall(require, "telescope.previewers")
    
    if not ok or not buffer_previewer_path then
        vim.notify("Failed to load Telescope previewer modules for patching", vim.log.levels.ERROR)
        return
    end
    
    -- Create a safer buffer setter function
    local function safe_buffer_set_lines(bufnr, start_idx, end_idx, strict_indexing, lines)
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return false
        end
        
        -- Use pcall to prevent errors
        local ok = pcall(vim.api.nvim_buf_set_lines, bufnr, start_idx, end_idx, strict_indexing, lines)
        return ok
    end
    
    -- Patch the preview_termopen function (common source of the error)
    local orig_termopen = previewers.new_termopen_previewer
    previewers.new_termopen_previewer = function(opts)
        opts = opts or {}
        
        -- Override the previewer's bufname_maker
        local orig_bufname = opts.bufname
        opts.bufname = function(...)
            local bufname = type(orig_bufname) == 'function' and orig_bufname(...) or nil
            -- Generate a unique buffer name to prevent conflicts
            return bufname or string.format("telescope-preview-%d", math.random(100000))
        end
        
        -- Create the original previewer
        local orig_previewer = orig_termopen(opts)
        
        -- Override the preview display
        local orig_preview_fn = orig_previewer.preview_fn
        orig_previewer.preview_fn = function(self, entry, status)
            -- Check if the preview buffer exists
            if status.preview_bufnr and not vim.api.nvim_buf_is_valid(status.preview_bufnr) then
                -- Create a new buffer if the existing one is invalid
                status.preview_bufnr = vim.api.nvim_create_buf(false, true)
                
                -- Set the buffer in the window
                pcall(vim.api.nvim_win_set_buf, status.preview_win, status.preview_bufnr)
            end
            
            -- Call the original preview function with error handling
            local ok, err = pcall(function() 
                orig_preview_fn(self, entry, status) 
            end)
            
            if not ok then
                -- Handle any errors in the preview function
                if vim.api.nvim_buf_is_valid(status.preview_bufnr) then
                    safe_buffer_set_lines(status.preview_bufnr, 0, -1, false, {
                        "Error displaying preview:",
                        tostring(err),
                        "Entry may not be previewable."
                    })
                end
            end
        end
        
        return orig_previewer
    end
    
    -- Replace the preview_buf_maker
    previewers.buffer_previewer_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        
        -- Basic checks
        if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        
        -- Check file accessibility first
        if vim.fn.filereadable(filepath) ~= 1 then
            safe_buffer_set_lines(bufnr, 0, -1, false, { "File not accessible" })
            return
        end
        
        -- Check file size
        local file_size = vim.fn.getfsize(filepath)
        if file_size > 100000 then
            safe_buffer_set_lines(bufnr, 0, -1, false, { "File too large to preview" })
            return
        end
        
        -- Manually read the file contents
        local lines = {}
        local file = io.open(filepath, "r")
        if not file then
            safe_buffer_set_lines(bufnr, 0, -1, false, { "Error reading file" })
            return
        end
        
        for line in file:lines() do
            table.insert(lines, line)
            if #lines > 500 then
                table.insert(lines, "... (file truncated)")
                break
            end
        end
        file:close()
        
        safe_buffer_set_lines(bufnr, 0, -1, false, lines)
    end
    
    -- Create a wrapper to make sure preview windows don't cause errors
    local orig_preview_window_maker = previewers.new_buffer_previewer
    previewers.new_buffer_previewer = function(opts)
        opts = opts or {}
        
        -- Override the preview_fn
        local orig_preview_fn = opts.preview_fn
        if orig_preview_fn then
            opts.preview_fn = function(self, entry, status)
                if not status.preview_win or not vim.api.nvim_win_is_valid(status.preview_win) then
                    return
                end
                
                if not status.preview_bufnr or not vim.api.nvim_buf_is_valid(status.preview_bufnr) then
                    status.preview_bufnr = vim.api.nvim_create_buf(false, true)
                    pcall(vim.api.nvim_win_set_buf, status.preview_win, status.preview_bufnr)
                end
                
                -- Call the original preview function with protection
                pcall(orig_preview_fn, self, entry, status)
            end
        end
        
        return orig_preview_window_maker(opts)
    end
    
    vim.notify("Successfully applied Telescope buffer previewer patches", vim.log.levels.INFO)
end

return M 