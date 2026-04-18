-- Global keymaps for PandaVim
-- Note: Plugin-specific keymaps are defined in their respective plugin specs

-- ============================================================================
-- Basic Options
-- ============================================================================

vim.o.relativenumber = true
vim.opt.hlsearch = false
vim.opt.termguicolors = true

-- ============================================================================
-- General Keymaps
-- ============================================================================

-- Select all
vim.keymap.set('n', '<C-a>', ':<C-u>normal! ggVG<CR>', { noremap = true, silent = true })

-- Better paste (don't yank replaced text) - Visual mode only
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Visual mode line movement
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Wrap/quote selected text
vim.keymap.set({ "n", "x" }, '<leader>r"', ':s/\\%V.*\\%V/"&"/')
vim.keymap.set({ "n", "x" }, "<leader>r'", ":s/\\%V.*\\%V/'&'/")
vim.keymap.set({ "n", "x" }, "<leader>r[", ":s/\\%V.*\\%V/[&]/")
vim.keymap.set({ "n", "x" }, "<leader>r{", ":s/\\%V.*\\%V/{&}/")
vim.keymap.set({ "n", "x" }, "<leader>r(", ":s/\\%V.*\\%V/(&)/")
vim.keymap.set({ "n", "x" }, "<leader>r{{", ":s/\\%V.*\\%V/{{--&--}}/")

-- Commenting shortcuts
vim.keymap.set({ "n", "x" }, '<leader>c', ':Commentary<CR>', { silent = true })

-- Window navigation (basic, will be overridden by smart-splits if available)
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- ============================================================================
-- VSFileName - Custom vertical split with file
-- ============================================================================

function _G.VSFileName()
    local file_name = vim.fn.input("Enter file name: ", "", "file")
    if vim.fn.filereadable(file_name) == 1 then
        vim.cmd('vsplit')
        vim.cmd('edit ' .. vim.fn.fnameescape(file_name))
        vim.cmd('wincmd r')
    else
        vim.notify("File does not exist: " .. file_name, vim.log.levels.WARN)
    end
end

vim.api.nvim_set_keymap('n', '<leader>vs', ':lua VSFileName()<CR>', { noremap = true, silent = true })

-- ============================================================================
-- Undotree
-- ============================================================================

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

-- ============================================================================
-- Buffer Management (using <leader>b prefix)
-- ============================================================================

-- Quick save and quit
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })
vim.keymap.set("n", "<leader>Q", ":qa!<CR>", { silent = true, desc = "Force quit all" })

-- ============================================================================
-- Escape from insert mode
-- ============================================================================

-- Escape from insert mode with Ctrl+Q (works across all platforms)
vim.keymap.set("i", "<C-q>", "<Esc>")

