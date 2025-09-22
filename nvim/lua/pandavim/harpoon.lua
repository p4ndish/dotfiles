local M = {}
vim.g.mapleader = " "

function M.setup()
    local harpoon = require("harpoon")
    
    -- Basic Harpoon configuration
    harpoon:setup({
        settings = {
            save_on_toggle = true,
            sync_on_ui_close = true,
        }
    })
    
    -- Create a list for navigation
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(file_paths, item.value)
        end
        
        require("telescope.pickers").new({}, {
            prompt_title = "Harpoon",
            finder = require("telescope.finders").new_table({
                results = file_paths,
            }),
            previewer = conf.file_previewer({}),
            sorter = conf.generic_sorter({}),
        }):find()
    end
    
    -- Set up keybindings
    vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end, { desc = "Harpoon: Add file" })
    vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon: Toggle menu" })
    
    -- Global variable to track the last accessed harpoon index
    if not _G.harpoon_last_index then
        _G.harpoon_last_index = 1
    end
    
    -- Circular navigation through harpoon marks
    vim.keymap.set("n", "<leader>p", function()
        local list = harpoon:list()
        local items = list.items
        
        if #items == 0 then
            vim.notify("No files in harpoon list", vim.log.levels.WARN)
            return
        end
        
        -- Calculate previous index with circular navigation
        local prev_index = _G.harpoon_last_index - 1
        if prev_index < 1 then
            prev_index = #items
        end
        
        -- Update global index and select the file
        _G.harpoon_last_index = prev_index
        list:select(prev_index)
    end, { desc = "Harpoon: Previous file (circular)" })
    
    vim.keymap.set("n", "<leader>n", function()
        local list = harpoon:list()
        local items = list.items
        
        if #items == 0 then
            vim.notify("No files in harpoon list", vim.log.levels.WARN)
            return
        end
        
        -- Calculate next index with circular navigation
        local next_index = _G.harpoon_last_index + 1
        if next_index > #items then
            next_index = 1
        end
        
        -- Update global index and select the file
        _G.harpoon_last_index = next_index
        list:select(next_index)
    end, { desc = "Harpoon: Next file (circular)" })
    
    -- Update the global index when directly selecting a file
    local function update_index_on_select(index)
        return function()
            local list = harpoon:list()
            if #list.items >= index then
                _G.harpoon_last_index = index
                list:select(index)
            else
                vim.notify("No file at index " .. index, vim.log.levels.WARN)
            end
        end
    end
    
    -- Telescope integration
    vim.keymap.set("n", "<leader>fm", function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon: Open in Telescope" })
    
    -- Direct file access
    vim.keymap.set("n", "<leader>1", update_index_on_select(1), { desc = "Harpoon: File 1" })
    vim.keymap.set("n", "<leader>2", update_index_on_select(2), { desc = "Harpoon: File 2" })
    vim.keymap.set("n", "<leader>3", update_index_on_select(3), { desc = "Harpoon: File 3" })
    vim.keymap.set("n", "<leader>4", update_index_on_select(4), { desc = "Harpoon: File 4" })
end

return M
