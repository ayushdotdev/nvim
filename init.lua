vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }
vim.opt.cursorline = true

vim.opt.swapfile = false
-- vim.opt.cmdheight = 0

vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.signcolumn = "yes"
vim.opt.foldenable = false

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ":update<CR> :source<CR>")
vim.keymap.set('n', '<leader>w', ":write<CR>")
vim.keymap.set('n', '<leader>q', ":quit<CR>")
vim.keymap.set('n', '<leader>r', ":restart<CR>")
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
vim.keymap.set('n', '<leader><leader>', ":Pick files<CR>")
vim.keymap.set('n', '<leader>d', ":Oil<CR>")
vim.keymap.set('n', 'zz', ':wq<CR>')

local gh = function (x)
    return "https://github.com/" .. x
end

local cb = function (x)
    return "https://codeberg.org/" .. x
end

vim.pack.add({
    { src = gh("nvim-lspconfig") },
    { src = gh("rebelot/kanagawa.nvim")},
    { src = gh("vossenwout/guts.nvim")},
    { src = gh("mason-org/mason.nvim") },
    { src = gh("nvim-treesitter/nvim-treesitter") },
    { src = gh("nvim-tree/nvim-web-devicons") },
    { src = gh("nvim-lualine/lualine.nvim") },
    { src = gh("nvim-mini/mini.pick") },
    { src = gh("stevearc/oil.nvim") },
--    { src = gh("rcarriga/nvim-notify")},
--    { src = gh("folke/noice.nvim")},
    { src = gh("saghen/blink.lib") },
    { src = gh("saghen/blink.cmp") },
    { src = gh("sudoscrawl/tokyo-night-dark.nvim") },
    { src = gh("MeanderingProgrammer/render-markdown.nvim")},
})


require("mini.pick").setup()
require("oil").setup()
require("mason").setup()
-- require("noice").setup()
require("render-markdown").setup({})

vim.lsp.enable({ "lua_ls", "pyright", "clangd"})
require("nvim-treesitter").setup({
    ensure_installed = {
        "lua",
        "python",
        "bash",
        "json",
        "javascript",
        "c",
    },
    highlight = {
        enable = true
    },

    indent = {
        enable = true
    }
})


vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    pcall(vim.treesitter.start)

    vim.bo.indentexpr =
      "v:lua.require'nvim-treesitter'.indentexpr()"

    vim.wo.foldexpr =
      "v:lua.vim.treesitter.foldexpr()"

    vim.wo.foldmethod = "expr"
  end,
})


require("blink.cmp").setup({
  keymap = {
    preset = "default",
  },

  appearance = {
    nerd_font_variant = "mono",
  },

  completion = {
    documentation = {
      auto_show = true,
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = {
    implementation = "prefer_rust_with_warning",
  },
})

--[[
require("catppuccin").setup {
    color_overrides = {
        all = {
                text = "#ffffff"
        },
        mocha = {
            base = "#000000",
            mantle = "#000000",
            crust = "#000000",
        },
    }
}
]]
require("lualine").setup()

vim.cmd("colorscheme guts")
vim.lsp.buf.hover()

--[[
local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup { indent = { highlight = highlight } }

]]
