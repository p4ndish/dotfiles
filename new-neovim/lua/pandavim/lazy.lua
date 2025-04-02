local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- Lazy.nvim can manage itself
    "folke/lazy.nvim",

    -- Theme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("pandavim.theme").setup()
        end
    },
    -- { "EdenEast/nightfox.nvim" },
    -- { "rebelot/kanagawa.nvim" },
    -- { "catppuccin/nvim", as = "catppuccin" },

    -- Utilities
    "tpope/vim-commentary",
    "j-hui/fidget.nvim",
    { "numToStr/Comment.nvim", config = true },

    -- Telescope & Dependencies
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("pandavim.telescope-config").setup()
        end
    },
    "nvim-telescope/telescope-media-files.nvim",
    "nvim-telescope/telescope-project.nvim",
    "nvim-telescope/telescope-file-browser.nvim",

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        cmd = {
            "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable", 
            "TSEnable", "TSDisable", "TSModuleInfo"
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "python", "javascript" },
                highlight = { enable = true }
            })
        end
    },

    -- LSP & Autocompletion
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
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
        end
    },
    { "HallerPatrick/py_lsp.nvim", dependencies = { "dharmx/toml.nvim" } },

    -- Flutter
    {
        "akinsho/flutter-tools.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
        }
    },

    -- Laravel
    {
        "adalessa/laravel.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "tpope/vim-dotenv",
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
        },
        cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
        lazy = true,
        config = true,
    },

    -- Other Plugins
    "mbbill/undotree",
    "tpope/vim-fugitive",
    "mg979/vim-visual-multi",
    "EmranMR/tree-sitter-blade",
    "nvim-lua/plenary.nvim",
    "Darazaki/indent-o-matic",

    -- Smart Splits
    { "mrjones2014/smart-splits.nvim", config = true },

    -- Harpoon
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("pandavim.harpoon").setup()
        end
    },

    -- File Explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    -- Bufferline
    "romgrk/barbar.nvim",

    -- Terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("pandavim.terminal").setup()
        end,
    },

    -- Tabnine
    { "codota/tabnine-nvim", build = "./dl_binaries.sh" },

    -- Autocomplete
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
        },
        config = function()
            require("pandavim.autocomplete").setup()
        end,
    },

    -- Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("pandavim.copilot").setup()
        end,
    }

})

