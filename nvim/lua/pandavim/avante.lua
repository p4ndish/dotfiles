local M = {}

function M.setup()
  require('avante').setup({
    -- Default Avante.nvim configuration options
    -- You can customize these as per your preference.
    -- These are common starting points:
    format_on_save = false, -- Whether to format file on save
    run_on_buf_write_pre = false, -- Whether to run on BufWritePre event
    always_show_hint = true, -- Always show hints
    auto_select = true, -- Auto select first hint
    accept_key = "<CR>", -- Key to accept suggestion
    next_key = "<M-j>", -- Key to move to next suggestion
    prev_key = "<M-k>", -- Key to move to previous suggestion
    show_diagnostics_hint = true, -- Show diagnostics hint
    -- For more options, refer to Avante.nvim's documentation.
    -- e.g., https://github.com/yetone/avante.nvim
    
    -- Correct placement for provider and providers configuration
    provider = "gemini", -- Specify the default provider to use
    providers = {
      gemini = {
        -- endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent",
        -- endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent",
        model = "gemini-1.5-flash", -- Ensure this model name is correct for the API
        temperature = 0.7,
       
      }
    },
  })
end

return M 