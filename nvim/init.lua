-- PandaVim - Neovim Configuration
-- Entry point that bootstraps lazy.nvim and loads all plugins

-- ============================================================================
-- PHASE 0: nvim 0.12.2 shim — vim.deprecated.health was removed but
-- vim.treesitter / vim.lsp still call it. Override unconditionally.
-- ============================================================================
vim.deprecated = vim.deprecated or {}
vim.deprecated.health = vim.deprecated.health or {}
vim.deprecated.health.add = vim.deprecated.health.add or function() end
package.loaded['vim.deprecated.health'] = vim.deprecated.health

-- nvim 0.12.2 shim: vim.hl / vim.highlight lost the `.priorities` table that
-- the bundled diagnostic.lua still reads via `vim.highlight.priorities.diagnostics`.
-- Missing it crashes every LSP diagnostic push with
-- "attempt to index field 'priorities' (a nil value)".
-- IMPORTANT: never touch `vim.hl` directly here — on this build it is a lazy
-- module whose loader errors when the runtime file is absent. Only mutate the
-- package cache (package.loaded) and the already-present `vim.highlight` shim.
do
  local default_priorities = {
    syntax          = 50,
    treesitter      = 100,
    semantic_tokens = 125,
    diagnostics     = 150,
    user            = 200,
  }

  -- Pull the real priorities table if the runtime module still exposes it.
  local ok_real, real_hl = pcall(require, 'vim.highlight')
  local priorities = (ok_real and type(real_hl) == 'table' and type(real_hl.priorities) == 'table')
    and real_hl.priorities or default_priorities

  -- Provide a cached stub for plugins that `require('vim.hl')`, and ensure the
  -- cached copy carries `.priorities`.
  local cached_hl = package.loaded['vim.hl']
  if type(cached_hl) ~= 'table' then
    cached_hl = { range = function() end, on_yank = function() end }
    package.loaded['vim.hl'] = cached_hl
  end
  if type(cached_hl.priorities) ~= 'table' then
    cached_hl.priorities = priorities
  end

  -- Repair vim.highlight (read by the bundled diagnostic underline handler).
  local hl_shim = rawget(vim, 'highlight')
  if type(hl_shim) == 'table' and type(hl_shim.priorities) ~= 'table' then
    pcall(function() vim.highlight.priorities = priorities end)
  end
end

-- nvim 0.12.2 shim: this build's bundled defaults `require('vim.tty')` during
-- core startup (BEFORE init.lua runs), but the runtime file is missing, which
-- crashes any TTY-attached session with "module 'vim.tty' not found". A
-- package.loaded shim here is too late. The real fix is the version-controlled
-- lua/vim/tty.lua shipped alongside this config — the config rtp is on the
-- vim.* module search path, so the pre-init require finds it there.

-- nvim 0.12.2 shim: the compiled default 'statusline' evaluates
-- `vim.diagnostic.status()` and `vim.ui.progress_status()` on every redraw, but
-- this build omits both functions. When diagnostics are present the statusline
-- throws "attempt to call field 'status' (a nil value)" via luaeval. The
-- statusline is evaluated lazily (after init.lua), so providing the functions
-- here fixes it. Implementations mirror upstream: a compact count summary and
-- an empty progress string.
if type(vim.diagnostic) == 'table' and type(vim.diagnostic.status) ~= 'function' then
  vim.diagnostic.status = function()
    local ok, counts = pcall(vim.diagnostic.count)
    if not ok or type(counts) ~= 'table' or next(counts) == nil then
      return ''
    end
    local S = vim.diagnostic.severity
    local order = { { S.ERROR, 'E' }, { S.WARN, 'W' }, { S.INFO, 'I' }, { S.HINT, 'H' } }
    local parts = {}
    for _, sev in ipairs(order) do
      local n = counts[sev[1]]
      if n and n > 0 then
        parts[#parts + 1] = sev[2] .. n
      end
    end
    return table.concat(parts, ' ')
  end
end

if type(vim.ui) == 'table' and type(vim.ui.progress_status) ~= 'function' then
  vim.ui.progress_status = function()
    return ''
  end
end

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
