-- Telescope and file finding plugins

return {
    -- Main Telescope plugin
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope git_files<CR>", desc = "Git files" },
            { "<leader>fs", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
            { "<leader>fp", "<cmd>Telescope project<CR>", desc = "Projects" },
            { "<leader>fd", "<cmd>Telescope file_browser<CR>", desc = "File browser" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-media-files.nvim", cmd = "Telescope" },
            { "nvim-telescope/telescope-project.nvim", cmd = "Telescope" },
            { "nvim-telescope/telescope-file-browser.nvim", cmd = "Telescope" },
        },
        config = function()
            local ok, telescope = pcall(require, "telescope")
            if not ok then
                vim.notify("Telescope not available", vim.log.levels.WARN)
                return
            end

            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    path_display = { "truncate" },
                    file_ignore_patterns = { "node_modules", ".git/" },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["<C-n>"] = actions.move_selection_next,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<C-c>"] = actions.close,
                            ["<Esc>"] = actions.close,
                            ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                            ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
                        },
                        n = {
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["<Down>"] = actions.move_selection_next,
                            ["<Up>"] = actions.move_selection_previous,
                            ["gg"] = actions.move_to_top,
                            ["G"] = actions.move_to_bottom,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["q"] = actions.close,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        path_display = { "smart" },
                        hidden = true,
                        no_ignore = false,
                        previewer = false,
                    },
                    buffers = {
                        path_display = { "smart" },
                        previewer = false,
                    },
                    grep_string = {
                        path_display = { "smart" },
                        previewer = false,
                    },
                    live_grep = {
                        path_display = { "smart" },
                        previewer = false,
                    },
                },
                extensions = {
                    media_files = {
                        filetypes = {"png", "webp", "jpg", "jpeg", "pdf"},
                        find_cmd = "rg"
                    },
                    project = {
                        base_dirs = {
                            "~/Documents",
                            { path = "~/Documents", max_depth = 2 }
                        },
                        hidden_files = true,
                    },
                    file_browser = {
                        theme = "dropdown",
                        hijack_netrw = true,
                        mappings = {
                            ["i"] = {},
                            ["n"] = {},
                        },
                        previewer = false,
                    },
                },
            })

            -- Load extensions AFTER setup with pcall
            pcall(function() telescope.load_extension("media_files") end)
            pcall(function() telescope.load_extension("project") end)
            pcall(function() telescope.load_extension("file_browser") end)
        end,
    },

    -- Harpoon for file marking
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        keys = {
            { "<leader>a", desc = "Harpoon: Add file" },
            { "<leader>h", desc = "Harpoon: Toggle menu" },
            { "<leader>[", desc = "Harpoon: Previous file" },
            { "<leader>]", desc = "Harpoon: Next file" },
            { "<leader>fm", desc = "Harpoon: Open in Telescope" },
            { "<leader>1", desc = "Harpoon: File 1" },
            { "<leader>2", desc = "Harpoon: File 2" },
            { "<leader>3", desc = "Harpoon: File 3" },
            { "<leader>4", desc = "Harpoon: File 4" },
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local ok, harpoon = pcall(require, "harpoon")
            if not ok then
                vim.notify("Harpoon not available", vim.log.levels.WARN)
                return
            end

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
                    sorter = conf.generic_sorter({}),
                }):find()
            end

            -- Global variable to track last accessed index
            if not _G.harpoon_last_index then
                _G.harpoon_last_index = 1
            end

            -- Keymaps
            vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end,
                { desc = "Harpoon: Add file" })
            vim.keymap.set("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
                { desc = "Harpoon: Toggle menu" })

            -- Circular navigation
            vim.keymap.set("n", "<leader>[", function()
                local list = harpoon:list()
                local items = list.items
                if #items == 0 then
                    vim.notify("No files in harpoon list", vim.log.levels.WARN)
                    return
                end
                local prev_index = _G.harpoon_last_index - 1
                if prev_index < 1 then
                    prev_index = #items
                end
                _G.harpoon_last_index = prev_index
                list:select(prev_index)
            end, { desc = "Harpoon: Previous file" })

            vim.keymap.set("n", "<leader>]", function()
                local list = harpoon:list()
                local items = list.items
                if #items == 0 then
                    vim.notify("No files in harpoon list", vim.log.levels.WARN)
                    return
                end
                local next_index = _G.harpoon_last_index + 1
                if next_index > #items then
                    next_index = 1
                end
                _G.harpoon_last_index = next_index
                list:select(next_index)
            end, { desc = "Harpoon: Next file" })

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

            vim.keymap.set("n", "<leader>fm", function() toggle_telescope(harpoon:list()) end,
                { desc = "Harpoon: Open in Telescope" })
            vim.keymap.set("n", "<leader>1", update_index_on_select(1), { desc = "Harpoon: File 1" })
            vim.keymap.set("n", "<leader>2", update_index_on_select(2), { desc = "Harpoon: File 2" })
            vim.keymap.set("n", "<leader>3", update_index_on_select(3), { desc = "Harpoon: File 3" })
            vim.keymap.set("n", "<leader>4", update_index_on_select(4), { desc = "Harpoon: File 4" })
        end,
    },
}
