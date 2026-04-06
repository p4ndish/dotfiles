# PandaVim Portability Fix Plan

## Goal
Make the configuration work without errors on fresh Ubuntu/other Linux installations.

## Root Causes Identified
1. **Module-level plugin requires** - Plugins required before lazy.nvim installs them
2. **Missing error handling** - No pcall() wrappers around optional features
3. **Hardcoded paths without existence checks** - LSP binaries, license files
4. **Colorscheme before plugin download** - tokyonight loaded before lazy installs it
5. **Duplicate/conflicting configurations** - Telescope, Laravel, Tabnine defined twice
6. **Environment dependencies** - Clipboard assumes xclip/xsel installed

---

## Phase 1: Fix Critical Loading Order Issues

### 1.1 Rewrite `init.lua` (Entry Point)

**Current Problem:** Loads modules that require plugins immediately

**New Structure:**
```lua
-- ~/.config/nvim/init.lua
-- PHASE 1: Set leader and essential options BEFORE anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Essential options that don't depend on plugins
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.hlsearch = false

-- PHASE 2: Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", 
        "--branch=stable", lazyrepo, lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- PHASE 3: Setup lazy.nvim with all plugins
require("lazy").setup({
    { import = "pandavim.plugins" }, -- Split plugin specs into separate files
}, {
    install = { colorscheme = { "habamax" } }, -- Fallback during install
    checker = { enabled = true },
})

-- PHASE 4: Load keymaps that don't depend on specific plugins
require("pandavim.remap")
```

### 1.2 Create Plugin Spec Directory Structure

Create new directory: `lua/pandavim/plugins/`

Move plugin specs from `lazy.lua` into separate files:
- `lua/pandavim/plugins/init.lua` - Core plugins
- `lua/pandavim/plugins/lsp.lua` - LSP-related plugins
- `lua/pandavim/plugins/telescope.lua` - Telescope + extensions
- `lua/pandavim/plugins/ai.lua` - Copilot, Avante, Tabnine
- `lua/pandavim/plugins/ui.lua` - Theme, file tree, terminal

Each file returns a table of plugin specs with proper `config` functions.

---

## Phase 2: Fix Module-Level Plugin Requires

### 2.1 Fix `remap.lua`

**Current Problem:** Lines 24-27, 133-137, 141-144 require smart-splits at module level

**Fix:** Wrap in function called after plugin loads
```lua
-- lua/pandavim/remap.lua
-- Only define keymaps that don't require plugins first
vim.g.mapleader = " "

-- Basic options
vim.o.relativenumber = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true

-- Basic keymaps (no plugin dependencies)
vim.keymap.set('n', '<C-a>', ':<C-u>normal! ggVG<CR>', {noremap = true, silent = true})

-- Plugin-dependent keymaps are set in their respective plugin config functions
-- This function is called by smart-splits plugin config
function _G.setup_smart_splits_keymaps()
    local ok, smart_splits = pcall(require, 'smart-splits')
    if not ok then
        vim.notify("smart-splits not loaded", vim.log.levels.WARN)
        return
    end
    
    vim.keymap.set('n', '<leader>sh', smart_splits.swap_buf_left)
    vim.keymap.set('n', '<leader>sj', smart_splits.swap_buf_down)
    vim.keymap.set('n', '<leader>sk', smart_splits.swap_buf_up)
    vim.keymap.set('n', '<leader>sl', smart_splits.swap_buf_right)
    vim.keymap.set('n', '<C-h>', smart_splits.move_cursor_left)
    vim.keymap.set('n', '<C-j>', smart_splits.move_cursor_down)
    vim.keymap.set('n', '<C-k>', smart_splits.move_cursor_up)
    vim.keymap.set('n', '<C-l>', smart_splits.move_cursor_right)
    vim.keymap.set('n', '<A-h>', smart_splits.resize_left)
    vim.keymap.set('n', '<A-j>', smart_splits.resize_down)
    vim.keymap.set('n', '<A-k>', smart_splits.resize_up)
    vim.keymap.set('n', '<A-l>', smart_splits.resize_right)
end
```

### 2.2 Fix `tabine.lua`

**Current Problem:** Runs setup at module level, loaded twice in init.lua

**Fix:** Move to lazy plugin spec
```lua
-- In lua/pandavim/plugins/ai.lua
{
    "codota/tabnine-nvim",
    build = "./dl_binaries.sh",
    config = function()
        local ok, tabnine = pcall(require, 'tabnine')
        if not ok then
            vim.notify("Tabnine not available", vim.log.levels.WARN)
            return
        end
        
        tabnine.setup({
            disable_auto_comment = true,
            accept_keymap = "<S-Tab>",
            dismiss_keymap = "<C-]>",
            debounce_ms = 800,
            suggestion_color = {gui = "#808080", cterm = 244},
            exclude_filetypes = {"TelescopePrompt", "NvimTree"},
            log_file_path = nil,
        })
    end,
}
```

### 2.3 Fix `filetree.lua`

**Current Problem:** Runs setup at module level

**Fix:** Move to lazy plugin spec
```lua
-- In lua/pandavim/plugins/ui.lua
{
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local ok, nvim_tree = pcall(require, "nvim-tree")
        if not ok then
            vim.notify("nvim-tree not available", vim.log.levels.WARN)
            return
        end
        
        local function my_on_attach(bufnr)
            local api = require "nvim-tree.api"
            local function opts(desc)
                return { desc = "nvim-tree: " .. desc, buffer = bufnr, 
                         noremap = true, silent = true, nowait = true }
            end
            api.config.mappings.default_on_attach(bufnr)
            vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
            vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        end
        
        nvim_tree.setup({ on_attach = my_on_attach })
        
        -- Set keymap after setup
        vim.keymap.set("n", "<leader>fo", vim.cmd.NvimTreeToggle, {silent = true})
        vim.keymap.set("n", "<leader>e", vim.cmd.NvimTreeToggle, {silent = true})
    end,
}
```

### 2.4 Fix Telescope Configuration

**Current Problem:** Two config files (telescope.lua, telescope-config.lua), extensions loaded before setup

**Fix:** Consolidate into single lazy spec
```lua
-- In lua/pandavim/plugins/telescope.lua
{
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { 
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-media-files.nvim",
        "nvim-telescope/telescope-project.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
        local ok, telescope = pcall(require, "telescope")
        if not ok then
            vim.notify("Telescope not available", vim.log.levels.WARN)
            return
        end
        
        local actions = require("telescope.actions")
        
        telescope.setup({
            defaults = {
                path_display = { "truncate" },
                file_ignore_patterns = { "node_modules", ".git/" },
                previewer = false,
                mappings = {
                    i = {
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<Esc>"] = actions.close,
                        ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
                    },
                    n = {
                        ["j"] = actions.move_selection_next,
                        ["k"] = actions.move_selection_previous,
                        ["q"] = actions.close,
                    },
                },
            },
            extensions = {
                media_files = { filetypes = {"png", "webp", "jpg", "jpeg", "pdf"}, find_cmd = "rg" },
            },
        })
        
        -- Load extensions AFTER setup
        pcall(telescope.load_extension, "media_files")
        pcall(telescope.load_extension, "project")
        pcall(telescope.load_extension, "file_browser")
        
        -- Set keymaps
        vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fg", ":Telescope git_files<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fs", ":Telescope live_grep<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", { noremap = true, silent = true })
    end,
}
```

---

## Phase 3: Fix Syntax and Runtime Errors

### 3.1 Fix `diagnostics.lua` Typo

**Line 20:** Change `underline = truek,` to `underline = true,`

### 3.2 Fix `packer.lua` or Delete It

Since packer is deprecated, either:
- Option A: Delete the file entirely
- Option B: Fix syntax error at lines 145-161

Recommended: **Delete it** - it's not used anyway.

### 3.3 Remove Duplicate `tabine` require in `init.lua`

**Current:** Lines 7 and 8 both require tabine
**Fix:** Remove line 8 (duplicate)

---

## Phase 4: Fix Path/File Existence Issues

### 4.1 Fix `intelephense.lua`

**Current Problem:** assert() crashes if license file missing, requires blink.cmp that doesn't exist

**Fix:**
```lua
-- lua/pandavim/intelephense.lua
local M = {}

function M.get_license()
    local license_path = os.getenv("HOME") .. "/intelephense/license.txt"
    local f = io.open(license_path, "rb")
    if not f then
        return nil -- Gracefully return nil if no license
    end
    local content = f:read("*a")
    f:close()
    return string.gsub(content, "%s+", "")
end

function M.get_config()
    local license = M.get_license()
    local config = {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php", "blade" },
        root_markers = { "composer.json", ".git" },
    }
    
    if license then
        config.init_options = { licenceKey = license }
    end
    
    return config
end

return M
```

### 4.2 Fix LSP Binary Paths in `lsp-config.lua`

**Current Problem:** Hardcoded paths to Mason binaries that may not exist

**Fix:** Create helper function to check binary existence
```lua
-- lua/pandavim/lsp-config.lua
local M = {}

-- Helper to check if a command exists
local function cmd_exists(cmd)
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not handle then return false end
    local result = handle:read("*a")
    handle:close()
    return result and result ~= ""
end

-- Helper to get Mason binary path with fallback
local function get_mason_bin(name)
    local mason_path = vim.fn.stdpath('data') .. '/mason/bin/' .. name
    if vim.fn.filereadable(mason_path) == 1 then
        return mason_path
    end
    -- Fallback to system binary
    if cmd_exists(name) then
        return name
    end
    return nil
end

function M.setup()
    local cmp = require('cmp')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    
    -- Only configure servers whose binaries exist
    local configs = {}
    
    -- Lua LSP
    local lua_ls = get_mason_bin("lua-language-server")
    if lua_ls then
        table.insert(configs, {
            name = 'lua_ls',
            cmd = { lua_ls },
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
        })
    else
        vim.notify("lua-language-server not found, skipping Lua LSP", vim.log.levels.WARN)
    end
    
    -- TypeScript
    local tsserver = get_mason_bin("typescript-language-server")
    if tsserver then
        table.insert(configs, {
            name = 'typescript-language-server',
            filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            cmd = { tsserver, '--stdio' },
            capabilities = capabilities,
        })
    end
    
    -- ... similar pattern for other LSPs
    
    -- Start configured servers
    for _, config in ipairs(configs) do
        vim.lsp.start(config)
    end
end

return M
```

### 4.3 Fix Copilot `root_dir` nil error

**Line 70 in copilot.lua:**
```lua
-- Current (dangerous):
root_dir = function()
    return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
end

-- Fixed (safe):
root_dir = function()
    local git_file = vim.fs.find(".git", { upward = true })[1]
    if git_file then
        return vim.fs.dirname(git_file)
    end
    return vim.fn.getcwd() -- Fallback to current directory
end
```

---

## Phase 5: Fix Environment Dependencies

### 5.1 Fix Clipboard for Linux

**In remap.lua, wrap clipboard setting:**
```lua
-- Check if clipboard tool is available
local function has_clipboard()
    local handle = io.popen("command -v xclip xsel 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result and result ~= ""
    end
    -- macOS has built-in clipboard support
    return vim.fn.has('mac') == 1
end

if has_clipboard() then
    vim.opt.clipboard = "unnamedplus"
else
    vim.notify("Clipboard support requires xclip or xsel (Linux)", vim.log.levels.WARN)
end
```

### 5.2 Fix Colorscheme Loading

**In theme.lua:**
```lua
local M = {}

function M.setup()
    local ok, tokyonight = pcall(require, "tokyonight")
    if not ok then
        vim.notify("Tokyonight theme not available, using default", vim.log.levels.WARN)
        return
    end
    
    tokyonight.setup({
        style = "storm",
        transparent = false,
        -- ... rest of config
    })
    
    -- Set colorscheme with fallback
    local ok2, _ = pcall(vim.cmd, "colorscheme tokyonight")
    if not ok2 then
        vim.notify("Failed to set tokyonight colorscheme", vim.log.levels.ERROR)
    end
end

return M
```

Then in lazy plugin spec:
```lua
{
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("pandavim.theme").setup()
    end
}
```

---

## Phase 6: Remove Duplicates and Consolidate

### 6.1 Remove Duplicate Laravel Plugin

In `lazy.lua`, keep only ONE of:
- `adalessa/laravel.nvim` (line 118) OR
- `adibhanna/laravel.nvim` (line 229)

Recommended: Keep `adibhanna/laravel.nvim` (newer fork)

### 6.2 Consolidate Tabnine Configuration

Remove `tabine.lua` entirely. Only use the setup in `autocomplete.lua` (which already has pcall).

### 6.3 Consolidate Telescope

Delete `telescope.lua` (legacy), keep only `telescope-config.lua` but fix it to be a proper lazy spec.

### 6.4 Fix Mapleader Consistency

Set `vim.g.mapleader = " "` ONLY in `init.lua` before lazy setup.
Remove all other `vim.g.mapleader = " "` lines from:
- remap.lua (lines 1, 77, 130)
- harpoon.lua (line 2)
- terminal.lua (line 51)

---

## Phase 7: Remove Annoying Print Statements

### 7.1 Replace prints with vim.notify

**diagnostics.lua line 62:**
```lua
-- Current:
print("Diagnostic navigation: <leader>er to show popup, <leader>en/ep to navigate")

-- Fixed: Remove or make conditional
-- Option A: Remove entirely
-- Option B: Only show once
if not vim.g.pandavim_diagnostics_shown then
    vim.notify("Diagnostics: <leader>er/en/ep", vim.log.levels.INFO)
    vim.g.pandavim_diagnostics_shown = true
end
```

**treesitter.lua:** Remove or comment out print statements in user commands

---

## Summary of File Changes

### Files to DELETE:
1. `lua/pandavim/packer.lua` - Deprecated, broken syntax
2. `lua/pandavim/telescope.lua` - Superseded by telescope-config.lua
3. `lua/pandavim/tabine.lua` - Duplicate config, move to lazy spec

### Files to REWRITE:
1. `init.lua` - Proper lazy.nvim bootstrap order
2. `lua/pandavim/lazy.lua` - Split into `lua/pandavim/plugins/*.lua`
3. `lua/pandavim/remap.lua` - Remove module-level plugin requires
4. `lua/pandavim/lsp-config.lua` - Add binary existence checks
5. `lua/pandavim/theme.lua` - Add pcall for colorscheme
6. `lua/pandavim/diagnostics.lua` - Fix typo, remove print
7. `lua/pandavim/intelephense.lua` - Remove assert(), add nil checks
8. `lua/pandavim/copilot.lua` - Fix root_dir nil error

### Files to MODIFY:
1. `lua/pandavim/autocomplete.lua` - Already has pcall, keep as is
2. `lua/pandavim/harpoon.lua` - Remove mapleader set
3. `lua/pandavim/terminal.lua` - Remove mapleader set
4. `lua/pandavim/filetree.lua` - Move to lazy spec
5. `lua/pandavim/treesitter.lua` - Remove print statements

### New Files to CREATE:
1. `lua/pandavim/plugins/init.lua` - Core plugins
2. `lua/pandavim/plugins/lsp.lua` - LSP plugins
3. `lua/pandavim/plugins/telescope.lua` - Telescope
4. `lua/pandavim/plugins/ai.lua` - AI assistants
5. `lua/pandavim/plugins/ui.lua` - UI plugins
6. `lua/pandavim/utils.lua` - Safe require helper

---

## Testing Checklist

After implementing fixes, test on fresh Ubuntu:

1. [ ] Delete `~/.local/share/nvim/` and `~/.config/nvim/` (backup first!)
2. [ ] Copy config to fresh location
3. [ ] Run `nvim` - should bootstrap lazy.nvim without errors
4. [ ] Wait for plugin installation to complete
5. [ ] Check `:messages` - should be empty or only warnings
6. [ ] Test keymaps work
7. [ ] Open a file - LSP should attach without errors
8. [ ] Test telescope (`<leader>ff`)
9. [ ] Test file tree (`<leader>e`)
10. [ ] Test terminal (`<leader>t`)

---

## Alternative Quick Fix (Minimal Changes)

If you want minimal changes instead of full restructure:

1. Add `pcall` around ALL `require()` statements in `init.lua`
2. Fix the `truek` typo in diagnostics.lua
3. Fix intelephense.lua to not use assert()
4. Fix copilot.lua root_dir nil check
5. Remove `tabine.lua` duplicate require
6. Delete `packer.lua`
7. Add binary existence checks in lsp-config.lua

This won't be as clean but will prevent most errors.
