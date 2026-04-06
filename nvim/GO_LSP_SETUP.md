# Go LSP Setup for PandaVim

## What was done:

1. **Added gopls to Mason ensure_installed list** in `lua/pandavim/plugins/lsp.lua`
2. **Added Go LSP configuration** to `lua/pandavim/lsp-config.lua`
3. **Added Go to Treesitter** for proper syntax highlighting

## Next steps to get Go LSP working:

### Option 1: Automatic Installation (Recommended)
1. Open Neovim: `nvim`
2. Run `:Mason` to open the Mason UI
3. Find `gopls` in the list and install it
4. Or run `:MasonInstall gopls`

### Option 2: Command Line Installation
```bash
# Install gopls manually
go install golang.org/x/tools/gopls@latest
```

### Option 3: Let Mason Auto-install
Since `automatic_installation = true` is set, Mason should automatically install gopls when you open a Go file.

## Verification steps:

1. **Check if gopls is installed:**
   ```bash
   which gopls
   # Should show path to gopls
   ```

2. **In Neovim, check LSP status:**
   - Open a Go file: `nvim test_go.go`
   - Run `:LspInfo`
   - You should see gopls attached to the buffer

3. **Test LSP features:**
   - Type `fmt.` and you should see autocomplete suggestions
   - Hover over `Println` and press `K` for documentation
   - Use `gd` to go to definition

## Troubleshooting:

If gopls is not working:

1. **Check Mason logs:** `:MasonLog`
2. **Check if gopls binary exists:** `ls ~/.local/share/nvim/mason/bin/gopls`
3. **Check LSP info:** `:LspInfo`
4. **Ensure you're in a Go project** (with go.mod file) or gopls might not activate

## Expected behavior:

- Autocomplete for Go standard library and your packages
- Error diagnostics (red underlines for syntax/type errors)
- Hover documentation with `K`
- Go to definition with `gd`
- Code actions with `<space>ca`
- Formatting with `<space>f`