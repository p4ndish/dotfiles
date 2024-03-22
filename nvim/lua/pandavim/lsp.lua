local lsp_zero = require('lsp-zero')
local lsp_config = require("lspconfig")
local dartExcludedFolders = {
    vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
    vim.fn.expand("$HOME/.pub-cache"),
    vim.fn.expand("/opt/homebrew/"),
    vim.fn.expand("$HOME/tools/flutter/"),
}


-- lsp_config["dartls"].setup({
--     capabilities = capabilities,
--     cmd = {
--         "dart",
--         "language-server",
--         "--protocol=lsp",
--         -- "--port=8123",
--         -- "--instrumentation-log-file=/Users/robertbrunhage/Desktop/lsp-log.txt",
--     },
--     filetypes = { "dart" },
--     init_options = {
--         onlyAnalyzeProjectsWithOpenFiles = false,
--         suggestFromUnimportedLibraries = true,
--         closingLabels = true,
--         outline = false,
--         flutterOutline = false,
--     },
--     settings = {
--         dart = {
--             analysisExcludedFolders = dartExcludedFolders,
--             updateImportsOnRename = true,
--             completeFunctionCalls = true,
--             showTodos = true,
--         },
--     },
-- })
lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})

end)

local lua_opts = lsp_zero.nvim_lua_ls()
require('lspconfig').lua_ls.setup(lua_opts)





local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})

end)

lsp_zero.setup()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

local cmp_select = {behavior = cmp.SelectBehavior.Select } 
cmp.setup ({
	sources = {
		{name = 'nvim_lsp'},
	},

	preselect = 'item',
	completion = {
		completeopt = 'menu,menuone,noinsert'
	},

	mapping = {
		['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
		['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
		['<Tab>'] = cmp_action.tab_complete(),
		['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
		['<CR>'] = cmp.mapping.confirm({ select = false } ),
		--	['<Tab>'] = cmp.mapping.complete(),
	}

})



-- Telling lsp 0 to accept my custom mapping 
local lsp = require('lsp-zero').preset({
  manage_nvim_cmp = {
    set_extra_mappings = true,
  }
})




require("fidget").setup({})
require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {

  },
  handlers = {
    lsp_zero.default_setup,
  },

})





-- require("nvim-lsp-installer").setup({
--     automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
--     ui = {
--         icons = {
--             server_installed = "✓",
--             server_pending = "➜",
--             server_uninstalled = "✗"
--         }
--     }
-- })
