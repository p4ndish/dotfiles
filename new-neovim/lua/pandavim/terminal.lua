local M = {}

function M.setup()
    local toggleterm = require("toggleterm")
    
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
        direction = "horizontal", -- 'vertical', 'horizontal', 'tab', 'float'
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
    
    -- Set up a basic terminal toggle with persistence options
    local term = require("toggleterm.terminal").Terminal:new({
        direction = "horizontal",
        on_open = function(term)
            vim.cmd("startinsert!")
        end,
        on_close = function(term)
            -- Save any important state here if needed
        end,
        persist_size = true,
        persist_mode = true,  -- Remember if you were in insert or normal mode
        auto_scroll = true,   -- Automatically scroll to the bottom when the terminal is reopened
    })
    
    function _term_toggle()
        term:toggle()
    end
    vim.g.mapleader = " "

    -- Set up the keybinding manually
    vim.api.nvim_set_keymap("n", "<leader>t", ":ToggleTerm<CR>", {noremap = true, silent = true})
    
    -- Custom terminal commands
    local Terminal = require("toggleterm.terminal").Terminal
    
    -- Lazygit terminal
    local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
    })
    
    function _lazygit_toggle()
        lazygit:toggle()
    end
    
    vim.api.nvim_set_keymap("n", "<leader>g", "<cmd>lua _lazygit_toggle()<CR>", {noremap = true, silent = true})
    
    -- Node terminal
    local node = Terminal:new({
        cmd = "node",
        hidden = true,
        direction = "float",
    })
    
    function _node_toggle()
        node:toggle()
    end
    
    vim.api.nvim_set_keymap("n", "<leader>tn", "<cmd>lua _node_toggle()<CR>", {noremap = true, silent = true})
    
    -- Python terminal
    local python = Terminal:new({
        cmd = "python",
        hidden = true,
        direction = "float",
    })
    
    function _python_toggle()
        python:toggle()
    end
    
    vim.api.nvim_set_keymap("n", "<leader>tp", "<cmd>lua _python_toggle()<CR>", {noremap = true, silent = true})
    
-- Terminal keybindings
    vim.keymap.set("n", "<leader>ti", function()
        local term_bufs = {}
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].buftype == "terminal" then
                table.insert(term_bufs, buf)
            end
        end
        
        if #term_bufs > 0 then
            vim.api.nvim_set_current_buf(term_bufs[#term_bufs])
            vim.cmd("startinsert")
        end
    end, { noremap = true, silent = true })

    -- Add this line to make Escape work in terminal mode
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true })
    vim.keymap.set("i", "<leader>q", "<C-\\><C-n>", { noremap = true, silent = true })

    -- Add these lines for window navigation from terminal mode
    vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
    vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
end

return M 