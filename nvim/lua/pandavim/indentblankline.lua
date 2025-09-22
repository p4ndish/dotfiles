local M = {}

function M.setup()
  require('ibl').setup({
    -- Default Indent Blankline configuration options
    -- You can customize these as per your preference.
    -- These are common starting points:
    scope = {
      enabled = true,
      show_exact_scope = true,
    },
    indent = {
      char = "│", -- The character to use for indent lines
      tab_char = "│", -- The character to use for tab indent lines
    },
    exclude = {
      filetypes = {
        "help",
        "terminal",
        "dashboard",
        "packer",
        "gitcommit",
        "NvimTree",
        "Trouble",
        "lazy",
      },
      buftypes = {
        "nofile",
        "prompt",
        "quickfix",
        "lazy",
      },
    },
    -- For more options, refer to Indent Blankline's documentation.
    -- e.g., https://github.com/lukas-reineke/indent-blankline.nvim
  })
end

return M 