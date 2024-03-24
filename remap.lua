vim.g.mapleader = "/"

vim.o.relativenumber = true
vim.opt.clipboard = "unnamedplus"


vim.opt.tabstop = 4 
vim.opt.softtabstop = 4 
vim.opt.shiftwidth = 4 -- Replace 4 with your desired tab width
vim.opt.expandtab = true
vim.opt.smartindent = true 
vim.opt.hlsearch = false 
vim.opt.termguicolors = true 

-- custom mappings for spliting files
-- vim.keymap.set({"n"}, "<leader>vs", vim.cmd.vsplit, opt  ) 
-- recommended mappings
-- resizing splits
-- these keymaps will also accept a range,
-- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
-- moving between splits
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)


function VSFileName()
    local file_name = vim.fn.input("Enter file name: ", "", "file")
    if vim.fn.filereadable(file_name) == 1 then
        vim.cmd('vsplit')
        vim.cmd('edit ' .. vim.fn.fnameescape(file_name))
        vim.cmd('wincmd r')
    else
        print("File does not exist: " .. file_name)
    end
end

vim.api.nvim_set_keymap('n', '<leader>vs', ':lua VSFileName()<CR>', {noremap = true, silent = true})

-- custom mappings 
vim.keymap.set("i", "<leader>q", "<Esc>")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({"x", "n", }, "<leader>p", "\"_dP")
-- commenting from insert mode 
 
vim.keymap.set({"n", "x"}, "<leader>r\"", ':s/\\%V.*\\%V/"&"/<CR>')
vim.keymap.set({"n", "x"}, "<leader>r'", ":s/\\%V.*\\%V/'&'/<CR>")
vim.keymap.set({"n", "x"}, "<leader>r[", ":s/\\%V.*\\%V/[&]/<CR>")
vim.keymap.set({"n", "x"}, "<leader>r{", ":s/\\%V.*\\%V/{&}/<CR>")
vim.keymap.set({"n", "x"}, "<leader>r(", ":s/\\%V.*\\%V/(&)/<CR>")
vim.keymap.set({"n", "x"}, "<leader>//", ":s/^/\\/\\/ /<CR>")
vim.keymap.set({"n", "x"}, "<leader>/#", ":s/^/# /<CR>")


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


local opts = { noremap = true, silent = true }
-- Visual-mode commands
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv" )
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv" )



-- comment selected list 
vim.keymap.set({"n", "x", 'i'}, '<leader>C', ':Commentary<CR>' ,  {} )
-- vim.keymap.set({"n", "x", 'i'}, '<leader>C', vim.cmd.Commentary, {}) 

vim.g.mapleader = " "
require('Comment').setup({
    mapping = {
        ---Line-comment toggle keymap
        line = '<leader>gcc',
        -- kjkjBlock-comment toggle keymap
        block = '<leader>gbc',

    },

})
-- Map the leader key (change <Leader> to your preferred key)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})





vim.api.nvim_set_keymap('n', '<leader>la', ':Laravel artisan<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>lr', ':Laravel routes<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>lm', ':Laravel related<CR>', { noremap = true, silent = true })


-- custom split

-- custom filetree commands 
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fo", vim.cmd.NvimTreeToggle, {silent = true})
