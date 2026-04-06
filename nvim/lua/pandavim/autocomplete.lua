-- Autocompletion configuration for PandaVim
-- nvim-cmp + LuaSnip setup

local M = {}

local popup_config = {
    max_visible_items = 6,
    live_resize = false,
}

local function popup_width()
    local columns = vim.o.columns
    local calculated = math.floor(columns * 0.4)
    return math.max(40, math.min(calculated, 100))
end

local function popup_window_options()
    return {
        border = 'rounded',
        max_width = popup_width(),
        winhighlight = 'Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
    }
end

local function clean_display_label(text)
    if type(text) ~= 'string' then
        return text
    end
    return (text:gsub('~+$', ''))
end

function M.setup()
    vim.opt.pumheight = popup_config.max_visible_items

    local ok, cmp = pcall(require, "cmp")
    local ok_luasnip, luasnip = pcall(require, "luasnip")
    local ok_lspkind, lspkind = pcall(require, "lspkind")

    if not ok or not ok_luasnip then
        vim.notify("Completion plugins not available", vim.log.levels.WARN)
        return
    end

    -- Load friendly-snippets with filetype filtering
    pcall(function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end)

    -- Configure LuaSnip
    luasnip.config.setup({
        enable_autosnippets = true,
        store_selection_keys = "<Tab>",
    })

    if popup_config.live_resize then
        local group = vim.api.nvim_create_augroup('PandaVimCmpResize', { clear = true })
        vim.api.nvim_create_autocmd('VimResized', {
            group = group,
            callback = function()
                pcall(function()
                    cmp.setup({
                        window = {
                            completion = cmp.config.window.bordered(popup_window_options()),
                            documentation = cmp.config.window.bordered(popup_window_options()),
                        },
                    })
                end)
            end,
        })
    end

    cmp.setup({
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        view = {
            entries = { follow_cursor = true },
        },
        window = {
            completion = cmp.config.window.bordered(popup_window_options()),
            documentation = cmp.config.window.bordered(popup_window_options()),
        },
        preselect = cmp.PreselectMode.None,
        sorting = {
            comparators = {
                function(entry1, entry2)
                    local filetype = vim.bo.filetype
                    if filetype == 'javascript' or filetype == 'javascriptreact' or
                       filetype == 'typescript' or filetype == 'typescriptreact' then
                        if entry1.source.name == 'nvim_lsp' and entry2.source.name ~= 'nvim_lsp' then
                            return true
                        elseif entry1.source.name ~= 'nvim_lsp' and entry2.source.name == 'nvim_lsp' then
                            return false
                        end

                        local label1 = entry1.completion_item.label or entry1.completion_item.insertText or ''
                        local label2 = entry2.completion_item.label or entry2.completion_item.insertText or ''

                        local is_html1 = label1:match('<.*>') or label1:match('</.*>') or label1:match('<.*/>')
                        local is_html2 = label2:match('<.*>') or label2:match('</.*>') or label2:match('<.*/>')

                        if is_html1 and not is_html2 then
                            return false
                        elseif not is_html1 and is_html2 then
                            return true
                        end
                    end
                    return nil
                end,
                cmp.config.compare.offset,
                cmp.config.compare.exact,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
            },
        },
        completion = {
            completeopt = "menu,menuone,noinsert,noselect",
        },
        experimental = {
            ghost_text = false,
        },
        mapping = cmp.mapping.preset.insert({
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-j>"] = cmp.mapping.select_next_item(),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({
                select = false,
                behavior = cmp.ConfirmBehavior.Replace,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp', priority = 1000 },
            { name = 'buffer', priority = 500 },
            { name = 'path', priority = 250 },
            { name = 'luasnip', priority = 100 },
        }),
        formatting = ok_lspkind and {
            format = lspkind.cmp_format({
                mode = 'symbol_text',
                maxwidth = 50,
                ellipsis_char = '...',
                before = function(entry, vim_item)
                    local filetype = vim.bo.filetype
                    if filetype == 'javascript' or filetype == 'javascriptreact' or
                       filetype == 'typescript' or filetype == 'typescriptreact' then
                        local label = vim_item.abbr or vim_item.word or vim_item.label or ''
                        local insert_text = entry.completion_item.insertText or ''
                        local detail = vim_item.menu or ''

                        local js_keywords = {
                            'const', 'let', 'var', 'function', 'class', 'import', 'export',
                            'if', 'else', 'for', 'while', 'do', 'switch', 'case', 'default',
                            'try', 'catch', 'finally', 'throw', 'return', 'break', 'continue',
                            'async', 'await', 'yield', 'typeof', 'instanceof', 'new', 'this',
                            'super', 'extends', 'implements', 'interface', 'type', 'enum',
                            'public', 'private', 'protected', 'static', 'readonly', 'abstract'
                        }

                        local is_js_keyword = false
                        for _, keyword in ipairs(js_keywords) do
                            if label:lower():match(keyword:lower()) or insert_text:lower():match(keyword:lower()) then
                                is_js_keyword = true
                                break
                            end
                        end

                        if entry.source.name == 'luasnip' then
                            local html_patterns = {
                                '^<.*>.*</.*>$',
                                '^<.*/>$',
                                '^<.*>$',
                                '<%w+><%w+>',
                            }

                            local texts_to_check = { label, insert_text, detail }
                            for _, text in ipairs(texts_to_check) do
                                for _, pattern in ipairs(html_patterns) do
                                    if text:match(pattern) then
                                        if not is_js_keyword then
                                            return nil
                                        end
                                    end
                                end
                            end

                            if (label:match('[<>]') or insert_text:match('[<>]')) and not is_js_keyword then
                                return nil
                            end
                        end
                    end
                    vim_item.abbr = clean_display_label(vim_item.abbr)
                    vim_item.menu = clean_display_label(vim_item.menu)
                    return vim_item
                end
            })
        } or nil,
    })

    -- Configure filetype-specific sources
    cmp.setup.filetype({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, {
        sources = cmp.config.sources({
            { name = 'nvim_lsp', priority = 1000 },
            { name = 'buffer', priority = 500 },
            { name = 'path', priority = 250 },
            { name = 'luasnip', priority = 100 },
        }),
        completion = {
            completeopt = "menu,menuone,noinsert,noselect",
        },
        sorting = {
            comparators = {
                function(entry1, entry2)
                    if entry1.source.name == 'nvim_lsp' and entry2.source.name ~= 'nvim_lsp' then
                        return true
                    elseif entry1.source.name ~= 'nvim_lsp' and entry2.source.name == 'nvim_lsp' then
                        return false
                    end
                    return nil
                end,
                cmp.config.compare.offset,
                cmp.config.compare.exact,
                cmp.config.compare.score,
                cmp.config.compare.recently_used,
                cmp.config.compare.locality,
                cmp.config.compare.kind,
                cmp.config.compare.sort_text,
                cmp.config.compare.length,
                cmp.config.compare.order,
            },
        },
    })

    cmp.setup.filetype({ 'html', 'xml' }, {
        sources = cmp.config.sources({
            { name = 'nvim_lsp', priority = 1000 },
            { name = 'luasnip', priority = 900 },
            { name = 'buffer', priority = 500 },
            { name = 'path', priority = 250 },
        })
    })
end

return M
