vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }

vim.opt.swapfile = false
vim.opt.wrap = false

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ":update<CR> :source<CR>")
vim.keymap.set('n', '<leader>w', ":write<CR>")
vim.keymap.set('n', '<leader>q', ":quit<CR>")

