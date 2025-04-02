local M = {}

function M.setup()
    local lsp_zero = require('lsp-zero')
    
    lsp_zero.on_attach(function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        
        -- Mappings
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, opts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function() 
            vim.lsp.buf.format { async = true } 
        end, opts)
    end)

    -- Configure Mason to automatically install LSP servers
    require('mason').setup({})
    require('mason-lspconfig').setup({
        ensure_installed = {
            'lua_ls',
            'pyright',
            'tsserver',
        },
        handlers = {
            lsp_zero.default_setup,
            lua_ls = function()
                -- Configure lua_ls for neovim
                require('lspconfig').lua_ls.setup({
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' }
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                        }
                    }
                })
            end,
        }
    })

    -- Configure Flutter tools if available
    pcall(function()
        require("flutter-tools").setup({
            lsp = {
                on_attach = lsp_zero.on_attach,
                capabilities = lsp_zero.get_capabilities(),
            }
        })
    end)

    -- Configure Python LSP if available
    pcall(function()
        require("py_lsp").setup({
            language_server = "pyright",
            capabilities = lsp_zero.get_capabilities(),
        })
    end)
end

return M 