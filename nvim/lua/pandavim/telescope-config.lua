local M = {}

function M.setup()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    telescope.setup({
        defaults = {
            path_display = { "truncate" },
            file_ignore_patterns = { "node_modules", ".git/" },
            previewer = false,
            file_previewer = false,
            grep_previewer = false,
            qflist_previewer = false,
            buffer_previewer = false,
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

    -- Load extensions
    pcall(function() telescope.load_extension("media_files") end)
    pcall(function() telescope.load_extension("project") end)
    pcall(function() telescope.load_extension("file_browser") end)
end

return M 