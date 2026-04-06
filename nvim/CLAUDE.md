# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common commands

### Start and validate the config
- `nvim`
- `nvim path/to/file.lua`
- `nvim .`
- `:checkhealth`
- `:checkhealth lazy`
- `:checkhealth mason`
- `:messages`

### Plugin and LSP management
- `:Lazy`
- `:Lazy sync`
- `:Lazy update`
- `:Lazy clean`
- `:Mason`
- `:MasonInstall <server>`
- `:MasonUpdate`
- `:LspInfo`
- `:MasonLog`
- `:TSUpdate`
- `:TSInstall <language>`

### Repo tooling status
- No repo-local test suite, linter, formatter config, or package/build manifest was found in this config directory.
- There is no single-test command in this repo. Validate changes by launching Neovim, running `:checkhealth`, and exercising the affected plugin/module in-editor.

## Architecture

- `init.lua` is the only entrypoint. It sets leader keys and essential options first, bootstraps `lazy.nvim`, imports all plugin specs from `lua/pandavim/plugins`, then loads `pandavim.remap` and `pandavim.indentation`.
- Plugin definitions are grouped by concern in `lua/pandavim/plugins/`:
  - `init.lua`: core utilities, theme, and lightweight always-available plugins
  - `ui.lua`: tree, terminal, bufferline, window movement, indent guides
  - `telescope.lua`: Telescope and Harpoon, mostly key-driven lazy loading
  - `lsp.lua`: Mason, LSP wiring, completion dependencies, Treesitter, Laravel/Flutter plugins
- Most behavior is configured inside plugin spec `config` functions, not in a central plugin registry. For feature work, start from the relevant file in `lua/pandavim/plugins/`.
- `lua/pandavim/lsp-config.lua` is the main LSP orchestration layer. `plugins/lsp.lua` mainly declares dependencies and lazy-loading boundaries, then calls `require("pandavim.lsp-config").setup()`.
- LSP startup is manual and defensive:
  - server binaries are resolved from Mason first, then `$PATH`
  - root detection is done with `vim.fs.find(...)`
  - servers are started from `FileType` autocmds so they attach to the actual opened buffer
  - servers are skipped cleanly when binaries are missing
  - ESLint adds a `BufWritePre` formatter hook
- `lua/pandavim/autocomplete.lua` owns `nvim-cmp` and LuaSnip setup. It contains custom JS/TS filtering and sorting logic to suppress HTML-like snippet noise, so completion changes for web languages usually belong there.
- Global keymaps live in `lua/pandavim/remap.lua`; plugin-specific keymaps are usually declared beside the plugin in `lua/pandavim/plugins/*.lua`.
- Filetype indentation is centralized in `lua/pandavim/indentation.lua`: JS/TS/web files use 2 spaces, Python/Lua/PHP/Dart use 4 spaces, and Go/Make/CMake use real tabs.
- `lazy-lock.json` is the plugin lockfile and is the authoritative snapshot of pinned plugin versions.

## Important repo-specific notes

- The previous AI stack and several legacy helper modules were removed. Do not assume AI plugin wiring exists in this repo now.
- `lua/pandavim/remap.lua` now owns only global non-LSP mappings; buffer-local LSP mappings are owned by `lua/pandavim/lsp-config.lua`.
- `install.sh` is not part of the normal Neovim config workflow; it downloads and executes an external binary from a third-party GitHub release. Do not use it as a validation or setup step for config changes.
