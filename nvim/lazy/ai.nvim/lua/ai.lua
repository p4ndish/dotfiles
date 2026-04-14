-- PandaVim AI - Main module
-- AI-powered coding assistant for Neovim

local M = {}

local config = require("ai.config")
local client = require("ai.client")
local skills = require("ai.skills")
local ui = require("ai.ui")
local inline_edit = require("ai.inline_edit")
local context = require("ai.context")
local diff = require("ai.diff")

--- Setup the AI module
-- @param user_config table|nil: User configuration
function M.setup(user_config)
    -- Setup configuration
    config.setup(user_config)

    -- Setup diff highlights
    diff.setup_highlights()

    -- Setup UI
    ui.setup()

    -- Setup inline edit
    inline_edit.setup()

    -- Register AI commands
    vim.api.nvim_create_user_command("AIClear", function()
        ui.close()
    end, {})

    vim.api.nvim_create_user_command("AISwitchModel", function(args)
        if args.args ~= "" then
            config.set_model(args.args)
        else
            vim.notify("Usage: AISwitchModel <model_name>", vim.log.levels.WARN)
        end
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("AISkills", function()
        ui.process_command("/skills")
    end, {})

    vim.api.nvim_create_user_command("AIProvider", function(args)
        if args.args ~= "" then
            config.set_provider(args.args)
        else
            vim.notify("Current provider: " .. config.get_provider(), vim.log.levels.INFO)
        end
    end, { nargs = "?" })

    -- Register keymaps
    vim.keymap.set("n", "<leader>ac", function()
        ui.toggle()
    end, { noremap = true, silent = true, desc = "AI: Toggle chat" })

    vim.keymap.set("n", "<leader>aq", function()
        ui.close()
    end, { noremap = true, silent = true, desc = "AI: Close chat" })

    vim.keymap.set("n", "<leader>ae", function()
        vim.cmd("AIEdit")
    end, { noremap = true, silent = true, desc = "AI: Edit selection/line" })

    vim.keymap.set("n", "<leader>as", function()
        vim.cmd("AISkills")
    end, { noremap = true, silent = true, desc = "AI: List skills" })

    vim.keymap.set("n", "<leader>am", function()
        local models = config.get_models(config.get_provider())
        local model_list = {}
        for _, m in ipairs(models) do
            table.insert(model_list, m)
        end
        table.sort(model_list)

        vim.ui.select(model_list, {
            prompt = "Select AI model:",
            format_item = function(m) return m end,
        }, function(choice)
            if choice then
                config.set_model(choice)
                vim.notify("Model set to: " .. choice, vim.log.levels.INFO)
            end
        end)
    end, { noremap = true, silent = true, desc = "AI: Switch model" })

    -- Focus switching keymaps
    vim.keymap.set("n", "<C-Left>", function()
        ui.focus_editor()
    end, { noremap = true, silent = true, desc = "AI: Focus editor" })

    vim.keymap.set("n", "<C-Right>", function()
        ui.focus_chat()
    end, { noremap = true, silent = true, desc = "AI: Focus chat" })

    vim.keymap.set("n", "<C-j>", function()
        ui.toggle()
    end, { noremap = true, silent = true, desc = "AI: Toggle chat (alt)" })

    -- File context keymap
    vim.keymap.set("n", "<leader>af", function()
        local bufnr = vim.api.nvim_get_current_buf()
        context.toggle_file_context(bufnr)
        ui.update_header()
    end, { noremap = true, silent = true, desc = "AI: Toggle file context" })

    vim.notify("PandaVim AI loaded!", vim.log.levels.INFO)
end

return M
