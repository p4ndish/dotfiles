local M = {}

function M.setup()
    -- Set up the Tokyo Night theme
    require("tokyonight").setup({
        -- Choose the style: "storm", "moon", "night", "day"
        style = "night",
        
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
            -- You can modify colors here if needed
            colors.LineNr = { fg = "#ffffff", bg = "#ffffff" }
            colors.CursorLineNr = { fg = "#ffffff", bold = true }
            -- Example: colors.bg = "#000000"
        end,
        
        -- Modify highlight groups
        on_highlights = function(highlights, colors)
            -- Make line numbers have white background and dark text
            highlights.LineNr = { fg = "#ffffff", bg = "#ffffff" }
            highlights.CursorLineNr = { fg = "#ffffff", bold = true }
            
            -- Also set the gutter background to white
            -- highlights.SignColumn = { bg = "#ffffff" }
            
            -- If you want the current line highlight to extend to the number column
            -- highlights.CursorLine = { bg = colors.bg_highlight }
        end,
    })
    
    -- Set the colorscheme
    vim.cmd("colorscheme tokyonight")
    
    -- Additional UI settings
    vim.opt.termguicolors = true
    vim.opt.background = "dark"
    
    -- Status line configuration
    vim.opt.laststatus = 3  -- Global statusline
    
    -- Cursor line highlighting
    vim.opt.cursorline = true
    
    -- Line numbers
    vim.opt.number = true
    vim.opt.relativenumber = true
    
    -- Sign column (for git signs, diagnostics, etc.)
    vim.opt.signcolumn = "yes"
    
    -- Highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
    })
end

return M 