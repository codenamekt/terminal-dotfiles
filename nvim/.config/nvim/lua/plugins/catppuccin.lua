return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = {
      flavour = "mocha",
      background = {
        light = "latte",
        dark = "mocha",
      },
      transparent_background = true,
      show_end_of_buffer = false,
      styles = {
        comments = { "italic" },
        keywords = { "italic" },
        functions = {},
        conditionals = {},
        loops = {},
        booleans = {},
        numbers = {},
        strings = {},
        types = {},
        variables = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = true,
        indent_blankline = {
          enabled = true,
          scope_enabled = true,
        },
        mini = true,
        noice = true,
        notify = true,
        which_key = true,
        bufferline = true,
        lualine = {},
        oil = true,
        todo_comments = true,
        trouble = true,
      },
      custom_highlights = function(colors)
        return {
          ["@lsp.type.comment"] = { fg = colors.overlay0 },
        }
      end,
    },
  },
}
