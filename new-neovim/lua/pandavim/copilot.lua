local M = {}

function M.setup()
    require("copilot").setup({
        panel = {
            enabled = true,
            auto_refresh = false,
            keymap = {
                jump_prev = "[[",
                jump_next = "]]",
                accept = "<CR>",
                refresh = "gr",
                open = "<M-CR>"
            },
            layout = {
                position = "bottom", -- | top | left | right
                ratio = 0.4
            },
        },
        suggestion = {
            enabled = true,
            auto_trigger = true,
            debounce = 75,
            keymap = {
                accept = "<C-y>",
                accept_word = "<C-w>",
                accept_line = "<C-l>",
                next = "<C-n>",
                prev = "<C-p>",
                dismiss = "<C-e>",
            },
        },
        filetypes = {
            yaml = false,
            markdown = true,
            help = false,
            gitcommit = false,
            gitrebase = false,
            hgcommit = false,
            svn = false,
            cvs = false,
            ["."] = false,
            -- Enable for all filetypes
            ["*"] = true,
        },
        logger = {
            file = vim.fn.stdpath("log") .. "/copilot-lua.log",
            file_log_level = vim.log.levels.OFF,
            print_log_level = vim.log.levels.WARN,
            trace_lsp = "off", -- "off" | "messages" | "verbose"
            trace_lsp_progress = false,
            log_lsp_messages = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 18.x
        workspace_folders = {},
        copilot_model = "",  -- Current LSP default is gpt-35-turbo, supports gpt-4o-copilot
        root_dir = function()
            return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
        end,
        should_attach = function(_, _)
            if not vim.bo.buflisted then
                logger.debug("not attaching, buffer is not 'buflisted'")
                return false
            end

            if vim.bo.buftype ~= "" then
                logger.debug("not attaching, buffer 'buftype' is " .. vim.bo.buftype)
                return false
            end

            return true
        end,
        server_opts_overrides = {
            trace = "verbose",
            settings = {
                advanced = {
                    listCount = 10,           -- #completions for panel
                    inlineSuggestCount = 3,   -- #completions for getCompletions
                },
            },
        },
    })

    -- Integration with nvim-cmp - IMPORTANT: This might be causing conflicts
    local has_cmp, cmp = pcall(require, "cmp")
    if has_cmp then
        -- Disable this integration temporarily to see if it fixes the issue
        -- cmp.event:on("menu_opened", function()
        --     vim.b.copilot_suggestion_hidden = true
        -- end)
        -- 
        -- cmp.event:on("menu_closed", function()
        --     vim.b.copilot_suggestion_hidden = false
        -- end)
    end
    
    -- Add status check command
    vim.api.nvim_create_user_command("CopilotStatus", function()
        local status = require("copilot.client").is_started() and "Running" or "Not running"
        vim.notify("Copilot status: " .. status, vim.log.levels.INFO)
    end, {})
    
    -- Add a keybinding to toggle Copilot
    vim.api.nvim_set_keymap("n", "<leader>cp", ":Copilot toggle<CR>", {noremap = true, silent = true})
end

return M