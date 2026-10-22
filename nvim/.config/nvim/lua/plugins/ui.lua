return {
  -- Tema: Catppuccin Mocha, el mismo que usa el escritorio
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        bufferline = true,
        blink_cmp = true,
        gitsigns = true,
        mini = { enabled = true },
        native_lsp = { enabled = true },
        neotree = true,
        telescope = { enabled = true },
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        -- Separadores redondeados (requieren Nerd Font)
        section_separators = { left = "\238\130\180", right = "\238\130\182" },
        component_separators = { left = "\226\148\130", right = "\226\148\130" },
      },
      sections = {
        lualine_c = { { "filename", path = 1 } },
      },
    },
  },

  -- Pestañas de buffers arriba
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        always_show_bufferline = false,
        offsets = {
          { filetype = "neo-tree", text = "Explorador", highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  -- Muestra los atajos disponibles al apretar leader
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "código" },
        { "<leader>f", group = "buscar" },
        { "<leader>g", group = "git" },
        { "<leader>x", group = "diagnósticos" },
      },
    },
  },
}
