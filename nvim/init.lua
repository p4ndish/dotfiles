-- PandaVim - Neovim Configuration
-- Entry point that bootstraps lazy.nvim and loads all plugins

-- ============================================================================
-- PHASE 1: Essential Setup (before anything else)
-- ============================================================================

-- Set leader keys FIRST (required before lazy.nvim loads)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Essential vim options (minimal set needed before plugins)
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.hlsearch = false
vim.opt.hidden = true

-- Clipboard (with fallback if tools not available)
if vim.fn.has('mac') == 1 then
    vim.opt.clipboard = "unnamedplus"
else
    -- Check for Linux clipboard tools
    local handle = io.popen("command -v xclip xsel 2>/dev/null | head -1")
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result:gsub("%s+$", "") ~= "" then
            vim.opt.clipboard = "unnamedplus"
        else
            vim.notify("Clipboard: install xclip or xsel for system clipboard support", vim.log.levels.WARN)
        end
    end
end

-- ============================================================================
-- PHASE 2: Bootstrap lazy.nvim
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "--branch=stable", lazyrepo, lazypath,
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PHASE 3: Setup lazy.nvim with all plugins
-- ============================================================================

require("lazy").setup({
    { import = "pandavim.plugins" },
}, {
    install = {
        -- Use a builtin colorscheme during installation
        colorscheme = { "habamax" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

-- ============================================================================
-- PHASE 4: Load keymaps and other configuration
-- ============================================================================

-- Load keymaps (after plugins are loaded)
require("pandavim.remap")

-- Load indentation configuration
require("pandavim.indentation").setup()
