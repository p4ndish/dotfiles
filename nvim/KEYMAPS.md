# PandaVim Keymaps Reference

## Leader Key

**Leader:** `Space` (set in `init.lua`)

> **Note:** All `<leader>` mappings use the Space key. Some legacy `<space>` mappings have been standardized to use `<leader>`.

---

## Platform Compatibility

| Platform | Notes |
|----------|-------|
| **macOS** | All keymaps work natively. `<A-*>` = Option key. `<C-*>` = Control key. |
| **Linux** | All keymaps work. `<A-*>` = Alt key. `<C-*>` = Control key. |
| **Windows** | All keymaps work. `<A-*>` = Alt key. `<C-*>` = Control key. `<C-q>` requires Windows Terminal settings (see below). |

### Windows-Specific Notes

**`<C-q>` for exiting insert mode:**
Windows Terminal may intercept `Ctrl+Q` as "close window". To fix:

1. Open Windows Terminal settings (Ctrl+,)
2. Add to `settings.json`:
```json
{
    "actions": [
        { "command": "unbound", "keys": "ctrl+q" }
    ]
}
```

Or use the alternative: `jj` or `jk` in insert mode (if added), or simply use the standard `Esc` key.

---

## Quick Reference by Category

### 🚀 Essentials

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>w` | Normal | Save file | ✅ All |
| `<leader>q` | Normal | Quit | ✅ All |
| `<leader>Q` | Normal | Force quit all | ✅ All |
| `<C-q>` | Insert | Exit to normal mode | ✅ macOS/Linux, ⚠️ Windows* |
| `<leader>h` | Normal | Show harpoon menu | ✅ All |

### 📁 File Operations

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>ff` | Normal | Find files (Telescope) | ✅ All |
| `<leader>fg` | Normal | Git files | ✅ All |
| `<leader>fs` | Normal | Live grep | ✅ All |
| `<leader>fb` | Normal | Browse buffers | ✅ All |
| `<leader>fp` | Normal | Browse projects | ✅ All |
| `<leader>fd` | Normal | File browser | ✅ All |
| `<leader>fe` | Normal | File tree (nvim-tree) | ✅ All |
| `<leader>a` | Normal | Harpoon: Add file | ✅ All |
| `<leader>1/2/3/4` | Normal | Harpoon: Jump to file 1-4 | ✅ All |
| `<leader>[` | Normal | Harpoon: Previous file | ✅ All |
| `<leader>]` | Normal | Harpoon: Next file | ✅ All |
| `<leader>fm` | Normal | Harpoon: Telescope view | ✅ All |

### 📝 Buffer Management

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>bp` | Normal | Previous buffer | ✅ All |
| `<leader>bn` | Normal | Next buffer | ✅ All |
| `<leader>bd` | Normal | Close buffer | ✅ All |
| `<leader>bD` | Normal | Close all but current | ✅ All |
| `<leader>bs` | Normal | Buffer pick (interactive) | ✅ All |
| `<leader>bpin` | Normal | Pin/unpin buffer | ✅ All |
| `<leader>bb` | Normal | Sort by buffer number | ✅ All |
| `<leader>bB` | Normal | Sort by directory | ✅ All |
| `<leader>bl` | Normal | Sort by language | ✅ All |
| `<leader>bw` | Normal | Sort by window number | ✅ All |
| `<A-1>` to `<A-9>` | Normal | Jump to buffer 1-9 | ✅ All |
| `<A-0>` | Normal | Jump to last buffer | ✅ All |
| `<A-<>` | Normal | Move buffer left | ✅ All |
| `<A->>` | Normal | Move buffer right | ✅ All |

### 🪟 Window Management

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<C-h>` | Normal | Move to left window | ✅ All |
| `<C-j>` | Normal | Move to below window | ✅ All |
| `<C-k>` | Normal | Move to above window | ✅ All |
| `<C-l>` | Normal | Move to right window | ✅ All |
| `<A-h>` | Normal | Resize window left | ✅ All |
| `<A-j>` | Normal | Resize window down | ✅ All |
| `<A-k>` | Normal | Resize window up | ✅ All |
| `<A-l>` | Normal | Resize window right | ✅ All |
| `<leader>sh` | Normal | Swap buffer left | ✅ All |
| `<leader>sj` | Normal | Swap buffer down | ✅ All |
| `<leader>sk` | Normal | Swap buffer up | ✅ All |
| `<leader>sl` | Normal | Swap buffer right | ✅ All |
| `<leader>vs` | Normal | Vertical split + open file | ✅ All |

### 🖥️ Terminal

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>tt` | Normal | Toggle terminal | ✅ All |
| `<leader>tg` | Normal | Lazygit terminal | ✅ All |
| `<leader>tn` | Normal | Node REPL | ✅ All |
| `<leader>tp` | Normal | Python REPL | ✅ All |
| `<Esc>` | Terminal | Exit terminal mode | ✅ All |
| `<C-h/j/k/l>` | Terminal | Navigate from terminal | ✅ All |

### 🌲 Git (Diffview + Fugitive)

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>gd` | Normal | Open diff view | ✅ All |
| `<leader>gD` | Normal | Close diff view | ✅ All |
| `<leader>gh` | Normal | File history | ✅ All |
| `<leader>gH` | Normal | Current file history | ✅ All |

**In Diffview:**
| Key | Action |
|-----|--------|
| `j/k` | Navigate files |
| `o` / `<Enter>` | Open file |
| `-` | Toggle stage/unstage |
| `s` | Stage file |
| `u` | Unstage file |
| `S` | Stage all |
| `U` | Unstage all |
| `X` | Restore file |
| `gf` | Go to file |
| `<leader>e` | Focus file panel |
| `<leader>b` | Toggle file panel |
| `q` | Close diffview |

### 🔧 LSP (Language Server)

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `gd` | Normal | Go to definition | ✅ All |
| `gD` | Normal | Go to declaration | ✅ All |
| `gi` | Normal | Go to implementation | ✅ All |
| `gr` | Normal | Show references | ✅ All |
| `K` | Normal | Hover documentation | ✅ All |
| `<C-k>` | Normal | Signature help | ✅ All |
| `<space>rn` | Normal | Rename symbol | ✅ All |
| `<space>ca` | Normal/Visual | Code action | ✅ All |
| `<space>f` | Normal | Format buffer | ✅ All |
| `<space>D` | Normal | Type definition | ✅ All |
| `<space>wa` | Normal | Add workspace folder | ✅ All |
| `<space>wr` | Normal | Remove workspace folder | ✅ All |
| `<space>wl` | Normal | List workspace folders | ✅ All |
| `<leader>er` | Normal | Show diagnostic popup | ✅ All |
| `<leader>en` | Normal | Next diagnostic | ✅ All |
| `<leader>ep` | Normal | Previous diagnostic | ✅ All |
| `<leader>el` | Normal | Add diagnostics to loclist | ✅ All |

### 🤖 AI Assistants

#### GitHub Copilot

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>cp` | Normal | Toggle Copilot | ✅ All |
| `<C-y>` | Insert | Accept suggestion | ✅ All |
| `<C-w>` | Insert | Accept word | ✅ All |
| `<C-l>` | Insert | Accept line | ✅ All |
| `<C-n>` | Insert | Next suggestion | ✅ All |
| `<C-p>` | Insert | Previous suggestion | ✅ All |
| `<C-e>` | Insert | Dismiss suggestion | ✅ All |

#### CopilotChat

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>zc` | Normal | Open Chat | ✅ All |
| `<leader>ze` | Visual | Explain code | ✅ All |
| `<leader>zr` | Visual | Review code | ✅ All |
| `<leader>zf` | Normal/Visual | Fix code issues | ✅ All |
| `<leader>zo` | Visual | Optimize code | ✅ All |
| `<leader>zd` | Visual | Generate docs | ✅ All |
| `<leader>zt` | Visual | Generate tests | ✅ All |
| `<leader>zm` | Normal/Visual | Generate commit message | ✅ All |

#### Tabnine

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<S-Tab>` | Insert | Accept suggestion | ✅ All |
| `<C-]>` | Insert | Dismiss suggestion | ✅ All |

### ✏️ Text Editing

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>p` | Visual | Paste without yank | ✅ All |
| `<leader>c` | Normal/Visual | Toggle comment | ✅ All |
| `<leader>r"` | Normal/Visual | Wrap with double quotes | ✅ All |
| `<leader>r'` | Normal/Visual | Wrap with single quotes | ✅ All |
| `<leader>r[` | Normal/Visual | Wrap with brackets | ✅ All |
| `<leader>r{` | Normal/Visual | Wrap with braces | ✅ All |
| `<leader>r(` | Normal/Visual | Wrap with parentheses | ✅ All |
| `<leader>r{{` | Normal/Visual | Wrap with Blade comments | ✅ All |
| `J` | Visual | Move selection down | ✅ All |
| `K` | Visual | Move selection up | ✅ All |
| `<Tab>` | Normal | Indent line | ✅ All |
| `<Tab>` | Visual | Indent selection | ✅ All |
| `<S-Tab>` | Normal | Unindent line | ✅ All |
| `<S-Tab>` | Visual | Unindent selection | ✅ All |
| `<leader>it` | Normal | Toggle tabs/spaces | ✅ All |
| `<leader>ti` | Normal | Show indent settings | ✅ All |

**Indentation by Filetype:**
| Filetype | Indent | Style |
|----------|--------|-------|
| JS/TS/JSON/HTML/CSS/Vue/Svelte/YAML | 2 spaces | `expandtab` |
| Python/Lua/PHP/Dart/Ruby/Rust/Java | 4 spaces | `expandtab` |
| Go/Makefile | 4 spaces | `noexpandtab` (tabs) |

### 🌐 Laravel (if in Laravel project)

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>la` | Normal | Artisan commands | ✅ All |
| `<leader>lc` | Normal | Composer | ✅ All |
| `<leader>lr` | Normal | Routes | ✅ All |
| `<leader>lm` | Normal | Make commands | ✅ All |

### 📜 Other

| Key | Mode | Action | Platforms |
|-----|------|--------|-----------|
| `<leader>u` | Normal | Undotree toggle | ✅ All |
| `<C-a>` | Normal | Select all | ✅ All |

---

## Keymap Changes Log

### Recent Changes (This Fix)

| Old Key | New Key | Reason |
|---------|---------|--------|
| `<leader>p` (Harpoon prev) | `<leader>[` | Conflict with paste |
| `<leader>n` (Harpoon next) | `<leader>]` | Consistency with `[` |
| `<leader>q` (Esc insert) | `<C-q>` | Reserve `<leader>q` for quit |
| `<space>bp/bn` | `<leader>bp/bn` | Standardize leader usage |
| `<space>wq` | `<leader>bd` | Consistent buffer delete |
| `<space>bs/bb/etc` | `<leader>bs/bb/etc` | Standardize leader usage |
| `<leader>l` (code action) | Removed | Duplicate of `<space>ca` |
| `<leader>e` | `<leader>fe` | Remove duplicate, consistent prefix |
| `<leader>C` | `<leader>c` | Easier to type |
| `<leader>g` | `<leader>tg` | Reserve `<leader>g` for git operations |
| `<leader>t` | `<leader>tt` | Consistent terminal prefix |
| `<leader>zf` + `<leader>cf` | `<leader>zf` only | Remove duplicate |

### New Additions

| Key | Action | Plugin |
|-----|--------|--------|
| `<leader>gd` | Open diff view | diffview.nvim |
| `<leader>gD` | Close diff view | diffview.nvim |
| `<leader>gh` | File history | diffview.nvim |
| `<leader>gH` | Current file history | diffview.nvim |

---

## Troubleshooting

### Keymap not working?

1. **Check leader key is set:**
   ```vim
   :echo mapleader
   " Should show ' ' (space)
   ```

2. **Check for conflicts:**
   ```vim
   :verbose nmap <leader>w
   " Shows what's mapped and where
   ```

3. **Terminal intercepting keys?** (Windows/WSL)
   - Windows Terminal: Check settings.json for keybindings
   - WSL: Check Windows Terminal key passthrough
   - tmux: Check prefix key conflicts (`<C-b>`)

4. **Alt key not working in terminal?**
   Add to `init.lua`:
   ```lua
   vim.opt.timeoutlen = 300
   vim.opt.ttimeoutlen = 10
   ```

### macOS Option Key as Alt

If `<A-*>` mappings don't work in iTerm2/Terminal.app:

**iTerm2:**
- Preferences → Profiles → Keys
- Set "Left Option Key" to "Esc+"

**Terminal.app:**
- Preferences → Profiles → Keyboard
- Check "Use Option as Meta key"

---

## Customizing Keymaps

To override any keymap, add to your `after/plugin/keymaps.lua` or modify the respective plugin config:

```lua
-- Example: Change save to <leader>s
vim.keymap.set("n", "<leader>s", ":w<CR>", { silent = true })

-- Unmap a default
vim.keymap.del("n", "<leader>w")
```

---

## Cheat Sheet (Printable)

```
ESSENTIALS
<leader>w       Save          <leader>q       Quit
<C-q>           Esc (insert)  <leader>Q       Force quit

FILES
<leader>ff      Find files    <leader>fg      Git files
<leader>fs      Live grep     <leader>fe      File tree
<leader>a       Harpoon add   <leader>1/2/3/4 Jump to file
<leader>[       Harpoon prev  <leader>]       Harpoon next

BUFFERS
<leader>bp      Prev buffer   <leader>bn      Next buffer
<leader>bd      Close buffer  <leader>bs      Pick buffer
<A-1>...<A-9>   Jump buffer   <A-p>           Pin buffer

WINDOWS
<C-h/j/k/l>     Navigate      <A-h/j/k/l>     Resize
<leader>sh/j/k/l Swap buffers <leader>vs      Vsplit + open

TERMINAL
<leader>tt      Terminal      <leader>tg      Lazygit
<leader>tn      Node REPL     <leader>tp      Python REPL

LSP
gd              Definition    gr              References
K               Hover         <space>ca       Code action
<space>rn       Rename        <space>f        Format
<leader>en/p    Diagnostics

AI
<leader>cp      Copilot       <C-y>           Accept suggestion
<leader>zc      Chat          <leader>ze      Explain (visual)
<leader>zf      Fix code      <leader>zm      Generate commit

GIT
<leader>gd      Diff view     <leader>gD      Close diff
<leader>gh      File history  <leader>gH      Current file

EDIT
<leader>p       Paste (visual)<leader>c        Comment
<leader>r"      Wrap quotes   J/K             Move selection
<Tab>           Indent        <leader>it      Toggle tabs
```
