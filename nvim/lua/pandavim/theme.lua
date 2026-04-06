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

    -- Status line configuration
    vim.opt.laststatus = 3

    -- Cursor line highlighting
    vim.opt.cursorline = true

    -- Line numbers
    vim.opt.number = true
    vim.opt.relativenumber = true

    -- Sign column
    vim.opt.signcolumn = "yes"

    -- Highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
    })
end

return M
