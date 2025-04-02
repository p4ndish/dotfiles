local M = {}

function M.setup()
    local telescope = require("telescope")
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
                    ["<C-p>"] = actions.move_selection_previous,
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
            },
            buffers = {
                path_display = { "smart" },
            },
            grep_string = {
                path_display = { "smart" },
            },
            live_grep = {
                path_display = { "smart" },
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
                    -- "~/work",
                    -- "~/personal",
                    { path = "~/Documents", max_depth = 2 }
                },
                hidden_files = true,
            },
            file_browser = {
                theme = "dropdown",
                hijack_netrw = true,
                mappings = {
                    ["i"] = {
                        -- your custom insert mode mappings
                    },
                    ["n"] = {
                        -- your custom normal mode mappings
                    },
                },
            },
        },
    })
    
    -- Load extensions
    telescope.load_extension("media_files")
    telescope.load_extension("project")
    
    -- Load file_browser extension if available
    pcall(function()
        telescope.load_extension("file_browser")
    end)
end

return M 