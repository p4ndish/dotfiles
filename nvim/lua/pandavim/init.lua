require("pandavim.remap")
require("pandavim.packer")
require("pandavim.lsp")
require("pandavim.telescope")
require("pandavim.treesitter")
require("pandavim.ntheme")
require("pandavim.tabconfig")
require("pandavim.flutter_Tool")


-- print("hello from custom file")
require("packer").startup(function(use)
  use { 'codota/tabnine-nvim', run = "./dl_binaries.sh" }
end)



