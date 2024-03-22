-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'tpope/vim-commentary'
  use "j-hui/fidget.nvim"

  use {
      'numToStr/Comment.nvim',
      config = function()
      end
  }
  use {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
        style = 'light',
        },
      config = function ()
      end
  }
  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.5',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }

    use {
        "williamboman/nvim-lsp-installer",
        "neovim/nvim-lspconfig",
    }
  use ({
	  "rose-pine/neovim",
	  as = "rose-pine",
	  config = function()
		  -- vim.cmd('colorscheme rose-pine')
	  end
  })

  use {
	  'nvim-treesitter/nvim-treesitter',

	  run = function()
		  local ts_update = require('nvim-treesitter.install').update({ with_sync = true })

		  ts_update()
	  end,
  }

  use(	'mbbill/undotree')
  use('tpope/vim-fugitive')
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
	  dependencies = { "dharmx/toml.nvim" },
  }



    use {
        'akinsho/flutter-tools.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
    }



end)
