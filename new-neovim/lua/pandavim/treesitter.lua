local M = {}

function M.setup()
    require('nvim-treesitter.configs').setup({
        ensure_installed = { "lua", "python", "javascript" },
        highlight = { enable = true },
        additional_vim_regex_highlighting = false,
    })
    
    -- Create a command to enable Treesitter for the current buffer
    vim.api.nvim_create_user_command("EnableTS", function()
        vim.cmd("TSBufEnable highlight")
        print("Treesitter highlighting enabled for this buffer")
    end, {})
end

return M
