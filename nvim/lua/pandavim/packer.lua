-- This file can be loaded by calling `lua require('plugins')` from your init.vim
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.cmd('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

vim.cmd('autocmd BufWritePost plugins.lua PackerCompile')
-- Only required if you have packer configured as `opt`

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use 'tpope/vim-commentary'
    use "j-hui/fidget.nvim"
    -- use "rebelot/kanagawa.nvim"
    -- use "EdenEast/nightfox.nvim" -- Packer
    -- use { "catppuccin/nvim", as = "catppuccin" }
    use {
        'numToStr/Comment.nvim',
        config = function()
        end
    }

    use {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    }
    use 'nvim-telescope/telescope-media-files.nvim'
    use 'nvim-telescope/telescope-project.nvim'
    

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.5',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    use {
        "williamboman/nvim-lsp-installer",
        "neovim/nvim-lspconfig",
    }
    -- use ({
    --     "rose-pine/neovim",
    --     as = "rose-pine",
    --     config = function()
    --         -- vim.cmd('colorscheme rose-pine')
    --     end
    -- })

    use {
        'nvim-treesitter/nvim-treesitter',

        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })

            ts_update()
        end,
    }

    use	'mbbill/undotree'
    use 'tpope/vim-fugitive'
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        requires = {
            --- Uncomment the two plugins below if you want to manage the language servers from neovim
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- LSP Support
            {'neovim/nvim-lspconfig'},
            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'L3MON4D3/LuaSnip'},
        }
    }

    use( 'mg979/vim-visual-multi', {branch = 'master'} )
    use {
        "HallerPatrick/py_lsp.nvim",
        requires = { "dharmx/toml.nvim" },
    }



    use {
        'akinsho/flutter-tools.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
    }

    use "EmranMR/tree-sitter-blade"

    use {
        'adalessa/laravel.nvim',
        requires = {
            'nvim-telescope/telescope.nvim',
            'tpope/vim-dotenv',
            'MunifTanjim/nui.nvim',
            'nvim-lua/plenary.nvim' -- Required by none-ls.nvim
        },
        cmd = { "Sail", "Artisan", "Composer", "Npm", "Yarn", "Laravel" },
    }

    use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" }

    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons',
            'nvim-tree/nvim-web-devicons', -- optional
        },

    }

    use 'romgrk/barbar.nvim'
    use { 'mrjones2014/smart-splits.nvim', build = './kitty/install-kittens.bash' }

end)
