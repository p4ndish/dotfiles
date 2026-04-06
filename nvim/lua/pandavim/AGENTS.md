# PandaVim — AI Agent Briefing

## Project Overview

PandaVim is a personal Neovim configuration written in Lua, designed for full-stack development with emphasis on PHP/Laravel, JavaScript/TypeScript, Python, Dart/Flutter, and Lua. The configuration provides an IDE-like experience with LSP support, AI coding assistants (GitHub Copilot, Avante with Gemini, Tabnine), fuzzy file finding via Telescope, terminal integration, and extensive keyboard-driven navigation.

**Tech Stack:**
- **Editor:** Neovim (latest stable)
- **Plugin Manager:** lazy.nvim
- **Languages:** Lua (configuration), with LSP support for TypeScript, Python, PHP, Dart, Lua
- **AI Assistants:** Copilot.lua, Avante.nvim (Gemini), Tabnine
- **File Navigation:** Telescope, Harpoon, nvim-tree
- **Terminal:** toggleterm.nvim

## Repository Structure

```
~/.config/nvim/
├── init.lua                      # Main entry point - bootstraps lazy.nvim
├── KEYMAPS.md                    # Comprehensive keymap documentation
├── CHANGES.md                    # Documentation of recent changes
├── lua/pandavim/                 # Core configuration modules
│   ├── utils.lua                 # Safe require, clipboard detection, helpers
│   ├── remap.lua                 # Global key mappings (no plugin deps)
│   ├── theme.lua                 # Tokyo Night theme with fallback
│   ├── lsp-config.lua            # LSP server setup with binary detection
│   ├── autocomplete.lua          # nvim-cmp + LuaSnip with pcall
│   ├── treesitter.lua            # Treesitter parser configuration
│   ├── harpoon.lua               # Harpoon module (called by plugin spec)
│   ├── indentation.lua           # Filetype-specific indentation rules
│   ├── diagnostics.lua           # LSP diagnostics display
│   ├── copilot.lua               # GitHub Copilot configuration
│   ├── avante.lua                # Avante.nvim AI assistant
│   ├── indentblankline.lua       # Indentation line visualization
│   ├── intelephense.lua          # PHP Intelephense LSP (safe license loading)
│   └── plugins/                  # Lazy.nvim plugin specifications
│       ├── init.lua              # Core plugins (theme, comments)
│       ├── telescope.lua         # Telescope + Harpoon
│       ├── ui.lua                # File tree, terminal, buffer line
│       ├── lsp.lua               # LSP, Mason, Treesitter, completion
│       └── ai.lua                # Copilot, Avante, Tabnine
```

## Setup and Installation

**Prerequisites:**
- Neovim ≥ 0.9 (latest stable recommended)
- Git
- Node.js > 20 (required for Copilot)
- A Nerd Font installed and configured in terminal (for icons)
- (Optional) `xclip` or `xsel` for system clipboard on Linux

**Installation:**

```bash
# Clone or symlink this config to ~/.config/nvim
# First backup existing config:
mv ~/.config/nvim ~/.config/nvim.backup

# Copy/symlink this configuration:
cp -r /path/to/pandavim ~/.config/nvim
# OR for development:
ln -s /path/to/pandavim ~/.config/nvim

# Launch Neovim - lazy.nvim will auto-install on first run:
nvim
```

**Post-Installation:**
1. On first launch, lazy.nvim will bootstrap itself and install all plugins
2. Mason will auto-install LSP servers: `lua_ls`, `pyright`, `typescript-language-server`, `eslint-lsp`, `tailwindcss-language-server`
3. Run `:checkhealth` to verify installation

**Intelephense License (Optional - for PHP):**
Place license file at `~/intelephense/license.txt` for PHP LSP premium features. Config will work without it (basic features only).

## Build and Run Commands

**Development (Running Neovim):**
```bash
# Start Neovim with this config
nvim

# Start with a specific file
nvim filename.lua

# Start in a directory
nvim .
```

**Plugin Management:**
```vim
" Inside Neovim - Lazy.nvim commands
:Lazy                    " Open plugin manager UI
:Lazy sync               " Update and clean plugins
:Lazy update             " Update all plugins
:Lazy clean              " Remove unused plugins
```

**LSP Management:**
```vim
:Mason                   " Open LSP server installer
:MasonUpdate             " Update LSP servers
:LspInfo                 " Show active LSP clients
```

**Treesitter:**
```vim
:TSUpdate                " Update all parsers
:TSInstall <language>    " Install specific parser
```

## Key Mappings Reference

**Leader Key:** `Space`

> For complete keymap documentation including platform-specific notes (macOS, Linux, Windows), see `KEYMAPS.md`.

### Quick Reference

#### Essentials
| Key | Action |
|-----|--------|
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>Q` | Force quit all |
| `<C-q>` | Exit insert mode (cross-platform) |
| `<leader>h` | Harpoon menu |

#### File Operations
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Git files |
| `<leader>fs` | Live grep |
| `<leader>fe` | File tree |
| `<leader>a` | Harpoon add |
| `<leader>[` / `]` | Harpoon prev/next |
| `<leader>1/2/3/4` | Harpoon files 1-4 |

#### Buffer Management
| Key | Action |
|-----|--------|
| `<leader>bp/bn` | Previous/Next buffer |
| `<leader>bd` | Close buffer |
| `<leader>bD` | Close all but current |
| `<leader>bs` | Pick buffer |
| `<A-1>` to `<A-9>` | Jump to buffer 1-9 |

#### Window Management
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Navigate windows |
| `<A-h/j/k/l>` | Resize windows |
| `<leader>sh/j/k/l` | Swap buffers |

#### Terminal
| Key | Action |
|-----|--------|
| `<leader>tt` | Toggle terminal |
| `<leader>tg` | Lazygit |
| `<leader>tn` | Node REPL |
| `<leader>tp` | Python REPL |

#### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover |
| `<space>ca` | Code action |
| `<space>rn` | Rename |
| `<space>f` | Format |
| `<leader>en/ep` | Next/Prev diagnostic |

#### AI Assistants
| Key | Action |
|-----|--------|
| `<leader>cp` | Toggle Copilot |
| `<C-y>` | Accept suggestion |
| `<leader>zc` | CopilotChat |
| `<leader>ze` | Explain code |
| `<leader>zf` | Fix code |

## Code Style and Conventions

**Lua Style:**
- Use 4-space indentation for Lua files
- Module pattern: `local M = {}` → functions → `return M`
- Always use `local` for variables unless global is intentional
- Prefer single quotes for strings unless interpolating

**Error Handling Pattern:**
```lua
local ok, module = pcall(require, 'module-name')
if not ok then
    vim.notify("Module not available: " .. tostring(module), vim.log.levels.WARN)
    return
end
-- Use module safely
```

**Plugin Loading Pattern:**
```lua
-- In lua/pandavim/plugins/*.lua
{
    "plugin/name",
    dependencies = { ... },
    config = function()
        local ok, plugin = pcall(require, "plugin-name")
        if not ok then return end
        plugin.setup({ ... })
        -- Set keymaps here
    end
}
```

**Keymap Conventions:**
- `<leader>` = Space key
- `<C-*>` = Control key (cross-platform)
- `<A-*>` = Alt key (Linux/Windows), Option key (macOS)
- Plugin-specific keymaps defined in plugin specs
- Global keymaps in `remap.lua`

## Architecture Notes

**Loading Order (Critical):**
1. `init.lua` sets `vim.g.mapleader = " "` FIRST
2. Bootstrap lazy.nvim
3. `require("lazy").setup({ import = "pandavim.plugins" })`
4. lazy.nvim loads plugin specs, installs missing plugins
5. Each plugin's `config` function runs when plugin loads
6. Finally, `init.lua` loads `remap.lua` for global keymaps

**Why This Structure:**
- Prevents "module not found" errors on fresh installs
- Allows graceful degradation if plugins are missing
- Follows lazy.nvim best practices
- Makes debugging easier with proper error messages

**LSP Binary Detection:**
LSP servers are only configured if their binaries exist:
1. Check Mason installation path first
2. Fallback to system PATH
3. Skip server gracefully if not found

**Clipboard on Linux:**
Config checks for `xclip` or `xsel` before enabling `unnamedplus`. If not found, shows warning but doesn't error.

**Theme with Fallback:**
Tokyonight is loaded with `pcall`. If unavailable (first install), falls back to built-in "habamax" colorscheme.

## Security Considerations

**Secrets Management:**
- Intelephense license loaded from `~/intelephense/license.txt` (gracefully handles missing file)
- Avante uses Gemini API (configured in `plugins/ai.lua`)
- Copilot requires GitHub authentication (handled by copilot.lua)

**Files Never to Commit:**
```
~/.config/nvim/lazy-lock.json    # Plugin versions (can be committed for reproducibility)
~/intelephense/license.txt       # Paid license key
```

**Safe Defaults:**
- `clipboard = "unnamedplus"` only if clipboard tool available
- No environment variable secrets in config files
- All external commands checked for existence before use

**External Network:**
- lazy.nvim downloads plugins from GitHub
- Mason downloads LSP server binaries
- Copilot/Avante/Tabnine make API calls to external services
- No proxy configuration in repository

## Troubleshooting

**Check health:**
```vim
:checkhealth
:checkhealth lazy
:checkhealth mason
```

**Reset plugin state:**
```bash
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/share/nvim/mason
nvim  # Will re-install everything
```

**LSP not working:**
```vim
:LspInfo          " Check if client attached
:Mason            " Verify server installed
:MasonLog         " Check for errors
```

**Check for missing binaries:**
```bash
which lua-language-server
which typescript-language-server
which pyright
```

**View startup errors:**
```vim
:messages
```

**Keymap conflicts:**
```vim
:verbose nmap <leader>w    " See what maps to <leader>w and where
```

## Migration from Old Config

If upgrading from the old config structure:

1. Back up old config: `mv ~/.config/nvim ~/.config/nvim.backup`
2. Copy new config to `~/.config/nvim`
3. Start nvim - lazy.nvim will install everything
4. Run `:Mason` to install LSP servers you need
5. Optional: Copy `~/intelephense/license.txt` if using PHP premium features

The new config is fully portable and will work on fresh Ubuntu without errors.

## Key Changes from Previous Version

### Keymap Changes

| Old | New | Reason |
|-----|-----|--------|
| `<leader>p` (Harpoon) | `<leader>[` / `]` | Conflict with paste |
| `<leader>q` (Esc) | `<C-q>` | Reserve for quit |
| `<space>bp/bn` | `<leader>bp/bn` | Standardize |
| `<space>wq` | `<leader>bd` | Consistency |
| `<leader>e` | `<leader>fe` | Remove duplicate |
| `<leader>l` | Removed | Duplicate of `<space>ca` |
| `<leader>C` | `<leader>c` | Easier to type |
| `<leader>g` | `<leader>tg` | Reserve for git |
| `<leader>t` | `<leader>tt` | Consistent |

### Architecture Changes

- Single `mapleader` definition in `init.lua`
- All plugin requires wrapped in `pcall()`
- LSP binary detection before starting servers
- Clipboard detection on Linux
- Theme loading with fallback
