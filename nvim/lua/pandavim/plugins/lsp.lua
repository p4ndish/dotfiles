-- LSP and completion plugins

return {
    -- Mason for LSP server management
    {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
        config = function()
            local ok, mason = pcall(require, "mason")
            if not ok then
                vim.notify("Mason not available", vim.log.levels.WARN)
                return
            end
            mason.setup()
        end,
    },

    -- Mason LSP config bridge
    {
        "williamboman/mason-lspconfig.nvim",
        ft = { "lua", "python", "javascript", "javascriptreact", "typescript", "typescriptreact", "go", "php", "dart" },
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            local ok, mason_lspconfig = pcall(require, "mason-lspconfig")
            if not ok then
                return
            end
            mason_lspconfig.setup({
                ensure_installed = {
                    'lua_ls',
                    'pyright',
                },
                automatic_installation = {
                    exclude = { 'gopls' }
                },
            })
        end,
    },

    -- LSP Zero for easier setup
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
        },
        config = function()
            require("pandavim.lsp-config").setup()
        end,
    },

    -- Python LSP helper
    { "HallerPatrick/py_lsp.nvim", ft = { "python" }, dependencies = { "dharmx/toml.nvim" } },

    -- Autocompletion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",
            },
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim",
            {
                "milanglacier/minuet-ai.nvim",
                event = "InsertEnter",
                dependencies = { "nvim-lua/plenary.nvim" },
                config = function()
                    require("pandavim.minuet").setup()
                end,
            },
        },
        config = function()
            require("pandavim.autocomplete").setup()
        end,
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local ok, treesitter = pcall(require, "nvim-treesitter.configs")
            if not ok then
                vim.notify("Treesitter not available", vim.log.levels.WARN)
                return
            end

            treesitter.setup({
                ensure_installed = {
                    "lua", "python", "javascript", "typescript", "go",
                    "html", "css", "json", "yaml", "markdown",
                    "bash", "vim", "vimdoc", "php", "dart"
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = false },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
            })

            -- User commands (without print statements)
            vim.api.nvim_create_user_command("EnableTS", function()
                vim.cmd("TSBufEnable highlight")
            end, {})

            vim.api.nvim_create_user_command("EnableTSIndent", function()
                vim.cmd("TSBufEnable indent")
            end, {})

            vim.api.nvim_create_user_command("DisableTSIndent", function()
                vim.cmd("TSBufDisable indent")
            end, {})
        end,
    },

    -- Flutter tools
    {
        "akinsho/flutter-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
        },
        ft = { "dart" },
        config = function()
            local ok, flutter_tools = pcall(require, "flutter-tools")
            if not ok then
                return
            end
            flutter_tools.setup({
                lsp = {
                    settings = { enableSnippets = true },
                },
            })
        end,
    },

    -- Laravel (keep only one)
    {
        "adibhanna/laravel.nvim",
        cmd = { "Artisan", "Composer", "LaravelRoute", "LaravelMake" },
        ft = { "php", "blade" },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>la", ":Artisan<cr>", desc = "Laravel Artisan" },
            { "<leader>lc", ":Composer<cr>", desc = "Composer" },
            { "<leader>lr", ":LaravelRoute<cr>", desc = "Laravel Routes" },
            { "<leader>lm", ":LaravelMake<cr>", desc = "Laravel Make" },
        },
        config = function()
            local ok, laravel = pcall(require, "laravel")
            if not ok then
                return
            end
            laravel.setup()
        end,
    },
}
