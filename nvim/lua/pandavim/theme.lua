-- Tokyo Night theme configuration for PandaVim

local M = {}

function M.setup()
    -- Try to load tokyonight
    local ok, tokyonight = pcall(require, "tokyonight")
    if not ok then
        vim.notify("Tokyonight theme not available, using default", vim.log.levels.WARN)
        return
    end

    tokyonight.setup({
        -- Choose the style: "storm", "moon", "night", "day"
        style = "storm",

        -- Make the theme transparent
        transparent = false,

        -- Configure terminal colors
        terminal_colors = true,

        -- Style options
        styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = {},
            variables = {},
            sidebars = "dark",
            floats = "dark",
        },

        -- Sidebar elements
        sidebars = { "qf", "help", "terminal", "packer", "NvimTree", "Trouble" },

        -- Make darker
        on_colors = function(colors)
            colors.LineNr = { fg = "#ffffff", bg = "#ffffff" }
            colors.CursorLineNr = { fg = "#ffffff", bold = true }
        end,

        -- Modify highlight groups
        on_highlights = function(highlights, colors)
            highlights.LineNr = { fg = "#ffffff", bg = "#ffffff" }
            highlights.CursorLineNr = { fg = "#ffffff", bold = true }
        end,
    })

    -- Set the colorscheme with fallback
    local ok2, _ = pcall(vim.cmd, "colorscheme tokyonight")
    if not ok2 then
        vim.notify("Failed to set tokyonight colorscheme", vim.log.levels.ERROR)
        -- Fallback to default
        pcall(vim.cmd, "colorscheme habamax")
    end

    -- Additional UI settings
    vim.opt.termguicolors = true
    vim.opt.background = "dark"

    -- Status line configuration: 2 = show when >=2 windows, 3 = per-window
    -- Keep at 2 so the AI sidebar can suppress its own statusline cleanly.
    vim.opt.laststatus = 2

    -- Cursor line highlighting
    vim.opt.cursorline = true

    -- Line numbers
    vim.opt.number = true
    vim.opt.relativenumber = true

    -- Sign column
    vim.opt.signcolumn = "yes"

    -- Highlight on yank (disabled on nvim 0.12+ — vim.highlight.on_yank internals
    -- try to require 'vim.hl' which was removed in this version)
    if vim.fn.has('nvim-0.12') == 0 then
        vim.api.nvim_create_autocmd("TextYankPost", {
            callback = function()
                pcall(vim.highlight.on_yank, { higroup = "IncSearch", timeout = 150 })
            end,
        })
    end
end

return M
