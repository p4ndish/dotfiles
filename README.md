# dotfiles

## Neovim Minuet AI setup

This repository uses `minuet-ai.nvim` for inline AI suggestions in Neovim.

### 1. Plugin location

The plugin is wired into the Neovim config here:
- `nvim/lua/pandavim/plugins/lsp.lua`

The provider configuration and switching commands live here:
- `nvim/lua/pandavim/minuet.lua`

The cmp integration and manual trigger live here:
- `nvim/lua/pandavim/autocomplete.lua`

### 2. Configure API keys

Set the provider credentials in your shell environment before launching Neovim.

```bash
export OPENAI_API_KEY="your-openai-key"
export DEEPSEEK_API_KEY="your-deepseek-key"
```

If you use a shell rc file, add them there and restart the shell.

### 3. Start Neovim from this config

```bash
XDG_CONFIG_HOME="$HOME/Documents/dotfiles" nvim
```

### 4. Default provider

The default provider is currently:
- OpenAI-compatible (`OPENAI_API_KEY`)

### 5. Switch providers inside Neovim

Commands:
- `:MinuetOpenAI`
- `:MinuetDeepSeek`

Keymaps:
- `<leader>ao` → switch to OpenAI-compatible
- `<leader>ad` → switch to DeepSeek FIM-compatible

### 6. Trigger inline AI suggestions

Manual cmp trigger:
- `<A-y>`

Minuet is also registered as a cmp source, so it participates in the completion flow with the rest of the current completion setup.

### 7. Notes

- If API keys are missing, Neovim should still start cleanly.
- Actual AI suggestions require valid provider credentials.
- Popup UI behavior is still owned by the cmp setup in `nvim/lua/pandavim/autocomplete.lua`.
