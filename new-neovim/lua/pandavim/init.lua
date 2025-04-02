require("pandavim.remap")
require("pandavim.packer")
require("pandavim.lsp")
require("pandavim.telescope")
require("pandavim.treesitter")
require("pandavim.ntheme")
require("pandavim.tabconfig")
require("pandavim.tabine")
require("pandavim.harpoon")
require("pandavim.filetree")
require("pandavim.flutter_Tool")
require("pandavim.nvim-cmp-autocomplete")


-- print("hello from custom file")
require("packer").startup(function(use)
  use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" }
end)



