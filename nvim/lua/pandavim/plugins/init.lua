-- Core plugins for PandaVim
-- Essential plugins that should load early

return {
    -- Lazy.nvim can manage itself
    "folke/lazy.nvim",

    -- Theme - High priority to load first
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("pandavim.theme").setup()
        end
    },

    -- Utilities
    { "tpope/vim-commentary", cmd = { "Commentary" } },
    { "tpope/vim-fugitive", cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gwrite", "Gread", "Ggrep", "GBrowse" } },
    { "mbbill/undotree", cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" } },
    { "mg979/vim-visual-multi", keys = { "<C-n>" } },
    
    -- Diffview for git diffs
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
            { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: File History" },
            { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: Current File History" },
        },
        config = function()
            local ok, diffview = pcall(require, "diffview")
            if not ok then
                vim.notify("diffview.nvim not available", vim.log.levels.WARN)
                return
            end
            
            diffview.setup({
                diff_binaries = false,
                enhanced_diff_hl = true,
                git_cmd = { "git" },
                use_icons = true,
                icons = {
                    folder_closed = "",
                    folder_open = "",
                },
                signs = {
                    fold_closed = "",
                    fold_open = "",
                    done = "✓",
                },
                view = {
                    default = {
                        layout = "diff2_horizontal",
                        winbar_info = false,
                    },
                    merge_tool = {
                        layout = "diff3_horizontal",
                        disable_diagnostics = true,
                        winbar_info = true,
                    },
                    file_history = {
                        layout = "diff2_horizontal",
                        winbar_info = false,
                    },
                },
                file_panel = {
                    listing_style = "tree",
                    tree_options = {
                        flatten_dirs = true,
                        folder_statuses = "only_folded",
                    },
                    win_config = {
                        position = "left",
                        width = 35,
                        win_opts = {},
                    },
                },
                file_history_panel = {
                    log_options = {
                        git = {
                            single_file = {
                                diff_merges = "combined",
                            },
                            multi_file = {
                                diff_merges = "first-parent",
                            },
                        },
                    },
                    win_config = {
                        position = "bottom",
                        height = 16,
                        win_opts = {},
                    },
                },
                commit_log_panel = {
                    win_config = {},
                },
                default_args = {
                    DiffviewOpen = {},
                    DiffviewFileHistory = {},
                },
                hooks = {},
                keymaps = {
                    disable_defaults = false,
                    view = {
                        ["<tab>"] = "select_next_entry",
                        ["<s-tab>"] = "select_prev_entry",
                        ["gf"] = "goto_file",
                        ["<C-w><C-f>"] = "goto_file_split",
                        ["<C-w>gf"] = "goto_file_tab",
                        ["<leader>e"] = "focus_files",
                        ["<leader>b"] = "toggle_files",
                    },
                    file_panel = {
                        ["j"] = "next_entry",
                        ["k"] = "prev_entry",
                        ["o"] = "select_entry",
                        ["<2-LeftMouse>"] = "select_entry",
                        ["-"] = "toggle_stage_entry",
                        ["s"] = "stage",
                        ["u"] = "unstage",
                        ["S"] = "stage_all",
                        ["U"] = "unstage_all",
                        ["X"] = "restore_entry",
                        ["R"] = "refresh_files",
                        ["<tab>"] = "select_next_entry",
                        ["<s-tab>"] = "select_prev_entry",
                        ["gf"] = "goto_file",
                        ["<C-w><C-f>"] = "goto_file_split",
                        ["<C-w>gf"] = "goto_file_tab",
                        ["i"] = "listing_style",
                        ["f"] = "toggle_flatten_dirs",
                        ["<leader>e"] = "focus_files",
                        ["<leader>b"] = "toggle_files",
                    },
                    file_history_panel = {
                        ["g!"] = "options",
                        ["<C-A-d>"] = "open_in_diffview",
                        ["y"] = "copy_hash",
                        ["L"] = "open_commit_log",
                        ["zR"] = "open_all_folds",
                        ["zM"] = "close_all_folds",
                        ["j"] = "next_entry",
                        ["k"] = "prev_entry",
                        ["o"] = "select_entry",
                        ["<2-LeftMouse>"] = "select_entry",
                        ["<tab>"] = "select_next_entry",
                        ["<s-tab>"] = "select_prev_entry",
                        ["gf"] = "goto_file",
                        ["<C-w><C-f>"] = "goto_file_split",
                        ["<C-w>gf"] = "goto_file_tab",
                        ["<leader>e"] = "focus_files",
                        ["<leader>b"] = "toggle_files",
                    },
                    option_panel = {
                        ["<tab>"] = "select",
                        ["q"] = "close",
                    },
                },
            })
        end,
    },
    
    -- Fidget for LSP progress
    {
        "j-hui/fidget.nvim",
        event = "LspAttach",
        config = true,
    },

    -- Code action indicator
    {
        "kosayoda/nvim-lightbulb",
        event = "LspAttach",
        config = function()
            local ok, lightbulb = pcall(require, "nvim-lightbulb")
            if not ok then
                return
            end
            lightbulb.setup({
                autocmd = { enabled = true }
            })
        end,
    },

    -- Plenary (required by many plugins)
    "nvim-lua/plenary.nvim",
}
