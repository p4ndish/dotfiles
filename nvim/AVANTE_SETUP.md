# Avante.nvim AI Provider Setup Guide

This guide explains how to configure different AI providers in PandaVim's Avante plugin.

## ⚠️ Important: Kimi vs Moonshot AI

There are **two separate services** with similar names:

| Service | URL | Purpose | Works with Avante? |
|---------|-----|---------|-------------------|
| **Kimi Code** | kimi.com/code/console | Web IDE for coding | ❌ No |
| **Moonshot AI** | platform.moonshot.cn | API service for developers | ✅ Yes |

**You need a Moonshot AI API key, not a Kimi Code key.**

---

## Getting Moonshot AI API Key (Correct Way)

1. Go to **https://platform.moonshot.cn/** (not kimi.com/code)
2. Create an account (may require China phone number)
3. Complete real-name verification
4. Go to "API Key Management" (API密钥管理)
5. Create a new API key
6. Copy the key (starts with `sk-`)

### Alternative: Using Kimi Code via OpenAI-Compatible Proxy

If you only have access to Kimi Code (kimi.com/code), you **cannot** use it directly with Avante. Instead:

1. Use **Google Gemini** (free, works globally)
2. Or use **OpenAI** with a proxy service

---

## Supported Providers

| Provider | Model | Environment Variable | Free Tier |
|----------|-------|---------------------|-----------|
| **Google Gemini** | gemini-1.5-flash | `GEMINI_API_KEY` | ✅ Yes |
| **Moonshot AI** | kimi-k2-5 | `KIMI_API_KEY` | ❌ No |
| **OpenAI** | gpt-4o-mini | `OPENAI_API_KEY` | ❌ No |
| **Anthropic Claude** | claude-3-5-sonnet | `ANTHROPIC_API_KEY` | ❌ No |

**Recommendation:** Use **Google Gemini** - it's free and works globally without phone verification.

---

## Quick Setup

### 1. Set API Keys

Add to your shell profile (`~/.zshrc`, `~/.bashrc`):

```bash
# Option 1: Google Gemini (Recommended - Free)
export GEMINI_API_KEY="your-gemini-api-key"

# Option 2: Moonshot AI (requires China phone number)
export KIMI_API_KEY="sk-your-moonshot-key"

# Option 3: OpenAI
export OPENAI_API_KEY="your-openai-key"
```

Reload shell:
```bash
source ~/.zshrc
```

### 2. Select Default Provider

Edit `~/.config/nvim/lua/pandavim/avante.lua`:

```lua
-- Change this line to switch providers
local default_provider = "gemini"  -- Options: "gemini", "kimi", "openai", "claude"
```

### 3. Restart Neovim

```bash
nvim
```

### 4. Verify Setup

Inside Neovim:
```vim
:AvanteCheckProviders
```

---

## Getting API Keys (Detailed)

### Google Gemini (Recommended - Free)

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with Google account
3. Click "Create API Key"
4. Copy key (starts with `AIza...`)

**Free tier:** 60 requests/minute, no credit card required

### Moonshot AI (China Only)

**⚠️ Requirements:**
- China phone number (+86)
- Real-name verification

1. Visit https://platform.moonshot.cn/
2. Sign up with China phone number
3. Complete identity verification
4. Purchase API credits (充值)
5. Create API key at "API密钥管理"
6. Copy key (starts with `sk-`)

**Pricing:** Pay per token usage

### OpenAI

1. Visit [OpenAI Platform](https://platform.openai.com/api-keys)
2. Add payment method
3. Create API key
4. Copy key (starts with `sk-`)

---

## Troubleshooting

### "Invalid Authentication" Error

This means your API key is:
1. **Wrong source** - Kimi Code key instead of Moonshot key
2. **Expired** - Key has been revoked
3. **Incorrect format** - Copy the full key including `sk-`

**Test your key:**
```bash
# For Gemini (should work)
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'

# For Moonshot (requires valid key)
curl https://api.moonshot.cn/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $KIMI_API_KEY" \
  -d '{"model":"kimi-k2-5","messages":[{"role":"user","content":"Hello"}]}'
```

### Can't Access Moonshot (No China Phone)

**Use Google Gemini instead:**

1. Get Gemini key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Set `GEMINI_API_KEY`
3. Change `default_provider = "gemini"`
4. Works globally, no phone required

### "Provider not found" Error

Check provider status:
```vim
:AvanteCheckProvider gemini
```

### Avante Not Loading

```vim
:Lazy sync
:lua require("pandavim.avante").setup()
```

---

## Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `:Avante` | Open Avante sidebar |
| `:AvanteAsk <question>` | Ask a question |
| `:AvanteChat` | Start chat session |
| `:AvanteEdit <instruction>` | Edit code |

### Keymaps

| Key | Mode | Action |
|-----|------|--------|
| `<leader>zc` | Normal | Open Chat |
| `<leader>ze` | Visual | Explain code |
| `<leader>zf` | Normal/Visual | Fix code |
| `<leader>zo` | Visual | Optimize |
| `<leader>zm` | Normal/Visual | Generate commit |

---

## Provider Configuration

```lua
-- In lua/pandavim/avante.lua
providers = {
    gemini = {
        endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
        model = "gemini-1.5-flash",
        api_key_name = "GEMINI_API_KEY",
        extra_request_body = {
            temperature = 0.7,
            max_tokens = 8192,
        },
    },
    
    kimi = {
        endpoint = "https://api.moonshot.cn/v1",
        model = "kimi-k2-5",
        api_key_name = "KIMI_API_KEY",
        extra_request_body = {
            temperature = 0.7,
            max_tokens = 8192,
        },
    },
}
```

---

## Recommendation

**For users outside China:** Use **Google Gemini**
- ✅ Free tier available
- ✅ No phone verification
- ✅ Global access
- ✅ Fast response times

**For users in China:** Use **Moonshot AI (Kimi)**
- ✅ Optimized for Chinese language
- ✅ Good code completion
- ⚠️ Requires China phone number

---

## Security

⚠️ **Never commit API keys!**

```bash
# Add to .gitignore
echo ".env" >> .gitignore

# Use environment variables only
export GEMINI_API_KEY="your-key"
```
