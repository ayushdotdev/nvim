return {
  "mason-org/mason-lspconfig.nvim",
  name = "mason-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig"
  },
  config = function()
    require("mason-lspconfig").setup {
      ensure_installed = { "pyright", "gopls", "html", "emmet_ls" },
      automatic_enable = true,
    }
  end
}
