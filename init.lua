vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }

vim.opt.swapfile = false
vim.opt.cmdheight = 0

vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ":update<CR> :source<CR>")
vim.keymap.set('n', '<leader>w', ":write<CR>")
vim.keymap.set('n', '<leader>q', ":quit<CR>")
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)

vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/nvim-mini/mini.pick" },
})


vim.lsp.enable({ "lua_ls" })


require("catppuccin").setup {
    color_overrides = {
        mocha = {
            base = "#000000",
            mantle = "#000000",
            crust = "#000000",
        }
    }
}
require("lualine").setup()
vim.cmd("colorscheme catppuccin-mocha")
