-- Indentation configuration for PandaVim
-- Filetype-specific indentation rules

local M = {}

function M.setup()
    -- Core indentation settings
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.smartindent = true
    vim.opt.autoindent = true
    vim.opt.smarttab = true

    -- File-type specific indentation settings
    -- JavaScript/TypeScript ecosystem (2 spaces)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "javascript", "typescript", "javascriptreact", "typescriptreact",
            "json", "jsonc", "html", "css", "scss", "sass", "less",
            "yaml", "yml", "vue", "svelte", "tsx", "jsx"
        },
        callback = function()
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.shiftwidth = 2
            vim.opt_local.expandtab = true
        end,
    })

    -- Python and similar (4 spaces)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "pyi", "lua", "php", "dart", "ruby", "rust", "kotlin", "java", "groovy" },
        callback = function()
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.opt_local.expandtab = true
        end,
    })

    -- Go and related (actual tabs, not spaces)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "gomod", "gowork", "gotmpl", "make", "cmake" },
        callback = function()
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 0
            vim.opt_local.shiftwidth = 4
            vim.opt_local.expandtab = false
        end,
    })

    -- Key mappings for manual indentation control
    vim.keymap.set('n', '<Tab>', '>>', { noremap = true, silent = true })
    vim.keymap.set('n', '<S-Tab>', '<<', { noremap = true, silent = true })
    vim.keymap.set('v', '<Tab>', '>gv', { noremap = true, silent = true })
    vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

    -- Function to toggle between tabs and spaces
    function _G.toggle_tabs()
        if vim.opt_local.expandtab:get() then
            vim.opt_local.expandtab = false
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 0
            vim.opt_local.shiftwidth = 4
            vim.notify("Switched to tabs", vim.log.levels.INFO)
        else
            vim.opt_local.expandtab = true
            vim.opt_local.tabstop = 4
            vim.opt_local.softtabstop = 4
            vim.opt_local.shiftwidth = 4
            vim.notify("Switched to spaces", vim.log.levels.INFO)
        end
    end

    vim.keymap.set('n', '<leader>it', ':lua toggle_tabs()<CR>', { noremap = true, silent = true, desc = "Toggle tabs/spaces" })

    -- Function to show current indentation settings
    function _G.show_indent_settings()
        local settings = {
            tabstop = vim.opt_local.tabstop:get(),
            softtabstop = vim.opt_local.softtabstop:get(),
            shiftwidth = vim.opt_local.shiftwidth:get(),
            expandtab = vim.opt_local.expandtab:get(),
        }
        local msg = "Indentation: "
        for key, value in pairs(settings) do
            msg = msg .. string.format("[%s=%s] ", key, tostring(value))
        end
        vim.notify(msg, vim.log.levels.INFO)
    end

    vim.keymap.set('n', '<leader>ti', ':lua show_indent_settings()<CR>', { noremap = true, silent = true })
end

return M
