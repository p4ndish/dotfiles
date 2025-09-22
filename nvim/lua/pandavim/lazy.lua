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
    -- Add nvim-lightbulb for code action indicator
    { 'kosayoda/nvim-lightbulb',
        config = function()
            require("nvim-lightbulb").setup({
                autocmd = { enabled = true }
            })
        end,
    },

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
        -- build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { 
                    "lua", "python", "javascript", "typescript", "html", "css", 
                    "json", "yaml", "markdown", "bash", "vim", "vimdoc"
                },
                auto_install = true,
                highlight = { 
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
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
    -- "EmranMR/tree-sitter-blade",
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

        config = function()
            require("pandavim.copilot").setup()

        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "nvim-lua/plenary.nvim", branch = "master" },
        },
        build = "make tiktoken",
        cmd = "CopilotChat", -- Add this line
        opts = {
            -- See Configuration section for options
        },
        keys = {
            { "<leader>zc", ":CopilotChat<CR>",         mode = "n", desc = "Chat with Copilot" },
            { "<leader>ze", ":CopilotChatExplain<CR>",  mode = "v", desc = "Explain Code" },
            { "<leader>zr", ":CopilotChatReview<CR>",   mode = "v", desc = "Review Code" },
            { "<leader>zf", ":CopilotChatFix<CR>",      mode = "v", desc = "Fix Code Issues" },
            { "<leader>cf", ":CopilotChatFix<CR>",      mode = "n", desc = "Fix Code Issues (Normal Mode)" },
            { "<leader>zo", ":CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
            { "<leader>zd", ":CopilotChatDocs<CR>",     mode = "v", desc = "Generate Docs" },
            { "<leader>zt", ":CopilotChatTests<CR>",    mode = "v", desc = "Generate Tests" },
            { "<leader>zm", ":CopilotChatCommit<CR>",   mode = "n", desc = "Generate Commit Message" },
            { "<leader>zs", ":CopilotChatCommit<CR>",   mode = "v", desc = "Generate Commit for Selection" },
        }

    },

    {
    "adibhanna/laravel.nvim",
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
        require("laravel").setup()
    end,
}, 


{
    "yetone/avante.nvim",
    config = function()
        require("pandavim.avante").setup()
    end,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }, 

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
    config = function()
        require("pandavim.indentblankline").setup()
    end 
}

})
