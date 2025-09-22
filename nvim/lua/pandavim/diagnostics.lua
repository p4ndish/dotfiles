local M = {}

function M.setup()
    -- Configure diagnostic signs
    local signs = {
        { name = "DiagnosticSignError", text = "E" },
        { name = "DiagnosticSignWarn", text = "W" },
        { name = "DiagnosticSignHint", text = "H" },
        { name = "DiagnosticSignInfo", text = "I" },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
    end

    -- Configure diagnostics display
    vim.diagnostic.config({
        virtual_text = false,
        signs = true,
        underline = truek,
        update_in_insert = false,
        severity_sort = false,
        float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })

    -- Set up hover with nicer border
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
            border = "rounded",
            width = 60,
        }
    )

    -- Set up signature help with nicer border
    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        vim.lsp.handlers.signature_help, {
            border = "rounded",
            width = 60,
        }
    )

    -- Diagnostic keymaps
    vim.keymap.set('n', '<leader>er', function()
        vim.diagnostic.open_float({ border = "rounded" })
    end, { desc = "Show diagnostics in popup", noremap = true, silent = true })
    
    vim.keymap.set('n', '<leader>ep', vim.diagnostic.goto_prev, 
        { desc = "Go to previous diagnostic", noremap = true, silent = true })
    
    vim.keymap.set('n', '<leader>en', vim.diagnostic.goto_next, 
        { desc = "Go to next diagnostic", noremap = true, silent = true })
    
    vim.keymap.set('n', '<leader>el', vim.diagnostic.setloclist, 
        { desc = "Add diagnostics to location list", noremap = true, silent = true })

    -- Quick tip
    print("Diagnostic navigation: <leader>er to show popup, <leader>en/ep to navigate")
end

return M 
