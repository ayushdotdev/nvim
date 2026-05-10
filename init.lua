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
vim.keymap.set('n', '<leader>r', ":restart<CR>")
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
vim.keymap.set('n', '<leader><leader>', ":Pick files<CR>")
vim.keymap.set('n', '<leader>d', ":Oil<CR>")

vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/nvim-mini/mini.pick" },
    { src = "https://github.com/stevearc/oil.nvim" },
})


require("mini.pick").setup()
require("oil").setup()
require("mason").setup()

vim.lsp.enable({ "lua_ls", "pyright" })
require("nvim-treesitter").setup({
    ensure_installed = {
        "lua",
        "python",
        "bash",
        "json",
        "javascript"
    },
    highlight = {
        enable = true
    },

    indent = {
        enable = true
    }
})


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

vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.cmd("colorscheme catppuccin-mocha")
