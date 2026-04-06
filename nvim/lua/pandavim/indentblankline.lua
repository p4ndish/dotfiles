-- Indent Blankline configuration for PandaVim

local M = {}

function M.setup()
    local ok, ibl = pcall(require, "ibl")
    if not ok then
        vim.notify("indent-blankline not available", vim.log.levels.WARN)
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
end

return M
