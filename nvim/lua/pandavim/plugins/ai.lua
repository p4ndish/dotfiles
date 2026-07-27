-- PandaVim AI — opencode.nvim (local development mode)
-- Plugin repo: https://github.com/p4ndish/opencode.nvim
-- Loaded from local directory so edits to the plugin are picked up on restart
-- without a push/pull cycle.

local plugin_dir = vim.fn.expand("~/Documents/opencode.nvim")

-- Guard: if the plugin directory is missing, emit a warning instead of
-- letting lazy.nvim fail loudly. Users can clone it from the GitHub mirror.
if vim.fn.isdirectory(plugin_dir) == 0 then
    vim.schedule(function()
        vim.notify(
            "PandaVim AI: plugin directory not found at " .. plugin_dir
                .. "\nClone https://github.com/p4ndish/opencode.nvim there to enable AI features.",
            vim.log.levels.WARN
        )
    end)
    return {}
end

return {
    {
        dir = plugin_dir,
        name = "opencode.nvim",
        main = "ai",
        event = "VeryLazy",
        -- Telescope is used by a few provider/model pickers (optional; the plugin
        -- falls back to vim.ui.select when telescope is absent).
        dependencies = { "nvim-telescope/telescope.nvim" },
        keys = {
            { "<leader>ac", function() require("ai.ui").toggle() end, desc = "AI: toggle sidebar" },
            { "<leader>ae", function() require("ai.inline_edit").start() end, desc = "AI: inline edit", mode = { "n", "v" } },
            { "<leader>am", function() vim.ui.select(require("ai.providers").get_models(), { prompt = "Select model" },
                function(model) require("ai.config").set_model(model) end) end, desc = "AI: pick model" },
            { "<leader>ay", function() vim.fn.setreg("+", vim.fn.getreg('"')) end, desc = "AI: copy last response" },
        },
        config = function()
            require("ai").setup({
                ui_mode = 'native',
            })

            -- Register :AIOpen/:AIClose/:AIToggle ex-commands.
            local ui = require("ai.ui")
            vim.api.nvim_create_user_command("AIOpen",   function() ui.open()   end, { desc = "AI: open sidebar" })
            vim.api.nvim_create_user_command("AIClose",  function() ui.close()  end, { desc = "AI: close sidebar" })
            vim.api.nvim_create_user_command("AIToggle", function() ui.toggle() end, { desc = "AI: toggle sidebar" })
        end,
    },
}
