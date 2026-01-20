return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup{
      color_overrides = {
        all = {
            text = "#ffffff",
          },
        mocha = {
          base = "#000000",
          crust = "#000000",
          mantle = "#000000",
        },
      }
      }
  end,

  }
