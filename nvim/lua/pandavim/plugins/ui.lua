-- UI-related plugins

return {
    -- File tree
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus", "NvimTreeClose" },
        keys = {
            { "<leader>fe", "<cmd>NvimTreeToggle<CR>", desc = "File Explorer" },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local ok, nvim_tree = pcall(require, "nvim-tree")
            if not ok then
                vim.notify("nvim-tree not available", vim.log.levels.WARN)
                return
            end

            local function my_on_attach(bufnr)
                local api = require("nvim-tree.api")
                local function opts(desc)
                    return {
                        desc = "nvim-tree: " .. desc,
                        buffer = bufnr,
                        noremap = true,
                        silent = true,
                        nowait = true
                    }
                end

                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
                vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
            end

            nvim_tree.setup({
                on_attach = my_on_attach,
            })
        end,
    },

    -- Buffer line (barbar)
    {
        "romgrk/barbar.nvim",
        event = "VeryLazy",
        config = function()
            local map = vim.api.nvim_set_keymap
            local opts = { noremap = true, silent = true }

            -- Buffer navigation with <leader>b prefix
            map('n', '<leader>bp', '<Cmd>BufferPrevious<CR>', opts)
            map('n', '<leader>bn', '<Cmd>BufferNext<CR>', opts)
            -- Close buffer
            map('n', '<leader>bd', '<Cmd>BufferClose<CR>', opts)
            map('n', '<leader>bD', '<Cmd>BufferCloseAllButCurrent<CR>', opts)
            -- Magic buffer-picking mode
            map('n', '<leader>bs', '<Cmd>BufferPick<CR>', opts)
            -- Sort buffers
            map('n', '<leader>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
            map('n', '<leader>bB', '<Cmd>BufferOrderByDirectory<CR>', opts)
            map('n', '<leader>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
            map('n', '<leader>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)
            -- Pin/unpin buffer
            map('n', '<leader>bpin', '<Cmd>BufferPin<CR>', opts)

            -- Alt keys for quick buffer switching (cross-platform)
            map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
            map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
            map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
            map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
            map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
            map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
            map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
            map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
            map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
            map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
            -- Re-order buffers
            map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
            map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)
        end,
    },

    -- Terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        event = "VeryLazy",
        config = function()
            local ok, toggleterm = pcall(require, "toggleterm")
            if not ok then
                vim.notify("toggleterm not available", vim.log.levels.WARN)
                return
            end

            toggleterm.setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                hide_numbers = true,
                shade_filetypes = {},
                shade_terminals = true,
                shading_factor = 2,
                start_in_insert = true,
                insert_mappings = true,
                persist_size = true,
                direction = "float",
                close_on_exit = true,
                shell = vim.o.shell,
                float_opts = {
                    border = "curved",
                    winblend = 0,
                    highlights = {
                        border = "Normal",
                        background = "Normal",
                    },
                },
            })

            local Terminal = require("toggleterm.terminal").Terminal

            -- Lazygit terminal (with executable check)
            local lazygit = Terminal:new({
                cmd = "lazygit",
                hidden = true,
                direction = "float",
                float_opts = {
                    border = "curved",
                },
                on_open = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            function _G._lazygit_toggle()
                if vim.fn.executable("lazygit") == 0 then
                    vim.notify("lazygit is not installed", vim.log.levels.ERROR)
                    return
                end
                lazygit:toggle()
            end

            -- Node terminal
            local node = Terminal:new({
                cmd = "node",
                hidden = true,
                direction = "float",
                on_open = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            function _G._node_toggle()
                if vim.fn.executable("node") == 0 then
                    vim.notify("node is not installed", vim.log.levels.ERROR)
                    return
                end
                node:toggle()
            end

            -- Python terminal
            local python = Terminal:new({
                cmd = vim.fn.executable("python3") == 1 and "python3" or "python",
                hidden = true,
                direction = "float",
                on_open = function(term)
                    vim.cmd("startinsert!")
                end,
            })

            function _G._python_toggle()
                if vim.fn.executable("python3") == 0 and vim.fn.executable("python") == 0 then
                    vim.notify("python is not installed", vim.log.levels.ERROR)
                    return
                end
                python:toggle()
            end

            -- Keymaps - use functions instead of commands
            vim.keymap.set("n", "<leader>tt", function()
                toggleterm.toggle(1, nil, nil, "float")
            end, { noremap = true, silent = true, desc = "Toggle Terminal" })

            vim.keymap.set("n", "<leader>tg", function()
                _G._lazygit_toggle()
            end, { noremap = true, silent = true, desc = "Lazygit" })

            vim.keymap.set("n", "<leader>tn", function()
                _G._node_toggle()
            end, { noremap = true, silent = true, desc = "Node REPL" })

            vim.keymap.set("n", "<leader>tp", function()
                _G._python_toggle()
            end, { noremap = true, silent = true, desc = "Python REPL" })

            -- Terminal navigation
            vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
            vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
            vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
            vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
            vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
        end,
    },

    -- Smart splits
    {
        "mrjones2014/smart-splits.nvim",
        event = "VeryLazy",
        config = function()
            local ok, smart_splits = pcall(require, "smart-splits")
            if not ok then
                vim.notify("smart-splits not available", vim.log.levels.WARN)
                return
            end

            smart_splits.setup()

            -- Window navigation
            vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left)
            vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down)
            vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up)
            vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right)
            vim.keymap.set('n', '<C-\\>', smart_splits.move_cursor_previous)

            -- Resizing
            vim.keymap.set('n', '<A-h>', smart_splits.resize_left)
            vim.keymap.set('n', '<A-j>', smart_splits.resize_down)
            vim.keymap.set('n', '<A-k>', smart_splits.resize_up)
            vim.keymap.set('n', '<A-l>', smart_splits.resize_right)

            -- Swapping buffers
            vim.keymap.set('n', '<leader>sh', smart_splits.swap_buf_left)
            vim.keymap.set('n', '<leader>sj', smart_splits.swap_buf_down)
            vim.keymap.set('n', '<leader>sk', smart_splits.swap_buf_up)
            vim.keymap.set('n', '<leader>sl', smart_splits.swap_buf_right)
        end,
    },

    -- Indentation visualization
    {
        "lukas-reineke/indent-blankline.nvim",
        event = { "BufReadPost", "BufNewFile" },
        main = "ibl",
        config = function()
            local ok, ibl = pcall(require, "ibl")
            if not ok then
                return
            end

            ibl.setup({
                scope = {
                    enabled = true,
                    show_exact_scope = true,
                },
                indent = {
                    char = "│",
                    tab_char = "│",
                },
                exclude = {
                    filetypes = {
                        "help",
                        "terminal",
                        "dashboard",
                        "packer",
                        "gitcommit",
                        "NvimTree",
                        "Trouble",
                        "lazy",
                    },
                    buftypes = {
                        "nofile",
                        "prompt",
                        "quickfix",
                        "lazy",
                    },
                },
            })
        end,
    },
}
