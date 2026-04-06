-- LSP Configuration for PandaVim
-- Sets up language servers with safe binary detection

local M = {}

-- Helper to check if a file is executable
local function is_executable(cmd)
    return vim.fn.executable(cmd) == 1
end

-- Helper to get Mason binary path with fallback
local function get_lsp_cmd(name)
    -- Try Mason path first
    local mason_path = vim.fn.stdpath('data') .. '/mason/bin/' .. name
    if vim.fn.filereadable(mason_path) == 1 then
        return { mason_path }
    end
    -- Fallback to system PATH
    if is_executable(name) then
        return { name }
    end
    return nil
end

-- Helper to find root directory
local function get_root_dir(patterns)
    local root_dir = nil
    for _, pattern in ipairs(patterns) do
        local found = vim.fs.find(pattern, { upward = true, type = 'file' })
        if found and #found > 0 then
            root_dir = vim.fs.dirname(found[1])
            break
        end
    end
    return root_dir or vim.fn.getcwd()
end

function M.setup()
    -- Fix nvim-lspconfig ESLint util if available
    pcall(function()
        local util = require('lspconfig.util')
        local original_insert_package_json = util.insert_package_json
        util.insert_package_json = function(config_files, section, filename)
            local result = original_insert_package_json(config_files, section, filename)
            if type(result) == 'table' then
                local flattened = {}
                for _, item in ipairs(result) do
                    if type(item) == 'string' then
                        table.insert(flattened, item)
                    elseif type(item) == 'table' then
                        for _, subitem in ipairs(item) do
                            if type(subitem) == 'string' then
                                table.insert(flattened, subitem)
                            end
                        end
                    end
                end
                return flattened
            end
            return result
        end
    end)

    local ok_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')

    -- Add additional capabilities supported by nvim-cmp when available
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if ok_cmp_lsp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Global mappings for LSP
    local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
        vim.keymap.set('n', '<leader>l', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, opts)
    end

    -- Get the LSP config module
    local lsp = vim.lsp

    -- Configure LSP servers - only if binaries exist
    local configs = {}

    -- Lua LSP
    local lua_ls_cmd = get_lsp_cmd('lua-language-server')
    if lua_ls_cmd then
        table.insert(configs, {
            name = 'lua_ls',
            cmd = lua_ls_cmd,
            filetypes = { 'lua' },
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                },
            },
            capabilities = capabilities,
            on_attach = on_attach,
        })
    else
        vim.notify("lua-language-server not found, skipping Lua LSP", vim.log.levels.INFO)
    end

    -- TypeScript/JavaScript
    local tsserver_cmd = get_lsp_cmd('typescript-language-server')
    if tsserver_cmd then
        table.insert(configs, {
            name = 'typescript-language-server',
            filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
            cmd = vim.list_extend(tsserver_cmd, { '--stdio' }),
            root_dir = function()
                return get_root_dir({ 'package.json', 'tsconfig.json', 'jsconfig.json' })
            end,
            capabilities = capabilities,
            on_attach = on_attach,
        })
    else
        vim.notify("typescript-language-server not found, skipping TypeScript LSP", vim.log.levels.INFO)
    end

    -- ESLint
    local eslint_cmd = get_lsp_cmd('vscode-eslint-language-server')
    if eslint_cmd then
        table.insert(configs, {
            name = 'eslint',
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
            cmd = vim.list_extend(eslint_cmd, { '--stdio' }),
            root_dir = function()
                return get_root_dir({ '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'package.json' })
            end,
            settings = {
                eslint = {
                    packageManager = 'npm',
                    format = { enable = true },
                    codeAction = {
                        disableRuleComment = { enable = true, location = 'separateLine' },
                        showDocumentation = { enable = true },
                    },
                    validate = 'on',
                    workingDirectory = { mode = 'auto' },
                }
            },
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                vim.api.nvim_create_autocmd('BufWritePre', {
                    buffer = bufnr,
                    callback = function()
                        if client.server_capabilities.documentFormattingProvider then
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end
                    end,
                })
                on_attach(client, bufnr)
            end,
        })
    end

    -- Tailwind CSS
    local tailwind_cmd = get_lsp_cmd('tailwindcss-language-server')
    if tailwind_cmd then
        table.insert(configs, {
            name = 'tailwindcss',
            filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
            cmd = vim.list_extend(tailwind_cmd, { '--stdio' }),
            init_options = {
                userLanguages = {
                    html = "html",
                    javascript = "javascript",
                    css = "css",
                },
            },
            root_dir = function()
                return get_root_dir({ 'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.ts' })
            end,
            capabilities = capabilities,
            on_attach = on_attach,
        })
    end

    -- Python
    local pyright_cmd = get_lsp_cmd('pyright-langserver')
    if pyright_cmd then
        table.insert(configs, {
            name = 'pyright',
            filetypes = { 'python' },
            cmd = vim.list_extend(pyright_cmd, { '--stdio' }),
            root_dir = function()
                return get_root_dir({ 'setup.py', 'pyproject.toml', 'requirements.txt' })
            end,
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "basic",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                    },
                },
            },
            capabilities = capabilities,
            on_attach = on_attach,
        })
    else
        vim.notify("pyright not found, skipping Python LSP", vim.log.levels.INFO)
    end

    -- Go LSP (gopls) - System installed
    local gopls_cmd = get_lsp_cmd('gopls')
    if gopls_cmd then
        table.insert(configs, {
            name = 'gopls',
            filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            cmd = gopls_cmd,
            root_dir = function()
                return get_root_dir({ 'go.mod', 'go.sum', '.git', 'go.work' })
            end,
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                        unusedwrite = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                    usePlaceholders = true,
                    completeUnimported = true,
                    matcher = 'fuzzy',
                    diagnosticsDelay = '500ms',
                    symbolMatcher = 'fuzzy',
                    vulncheck = 'Imports',
                    codelenses = {
                        generate = true,
                        gc_details = true,
                        regenerate_cgo = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
            capabilities = capabilities,
            on_attach = on_attach,
        })
        vim.notify("gopls found at: " .. table.concat(gopls_cmd, " "), vim.log.levels.INFO)
    else
        vim.notify("gopls not found, skipping Go LSP", vim.log.levels.INFO)
    end

    local group = vim.api.nvim_create_augroup('PandaVimLspStart', { clear = true })

    -- Start configured LSP servers when matching filetypes open
    for _, config in ipairs(configs) do
        vim.api.nvim_create_autocmd('FileType', {
            group = group,
            pattern = config.filetypes,
            callback = function(args)
                local server_config = {
                    name = config.name,
                    cmd = config.cmd,
                    filetypes = config.filetypes,
                    settings = config.settings,
                    capabilities = config.capabilities,
                    on_attach = config.on_attach,
                    init_options = config.init_options,
                }

                if config.root_dir then
                    server_config.root_dir = type(config.root_dir) == 'function' and config.root_dir() or config.root_dir
                end

                lsp.start(server_config, {
                    bufnr = args.buf,
                })
            end,
        })
    end

    -- Global LSP settings
    vim.diagnostic.config({
        virtual_text = {
            spacing = 2,
            source = 'if_many',
            prefix = '●',
        },
        signs = true,
        update_in_insert = false,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
            style = 'minimal',
            border = 'rounded',
            source = 'if_many',
            header = '',
            prefix = '',
        },
    })

    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
    })

    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = 'rounded',
    })

    vim.api.nvim_create_autocmd('CursorHold', {
        callback = function()
            vim.diagnostic.open_float(nil, { focusable = false })
        end,
    })

end

return M
