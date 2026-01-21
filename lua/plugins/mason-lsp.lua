return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = {"neovim/nvim-lspconfig"},
  config = function()
    require("mason-lspconfig").setup{
      ensure_installed = {"pyright", "gopls", "html_ls"},
      automatic_enable = true
    }
  end
}
