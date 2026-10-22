return {
  -- Buscador difuso: archivos, texto, buffers (requiere ripgrep y fd)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Archivos" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Buscar en proyecto" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recientes" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Ayuda" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
      },
    },
  },

  -- Explorador de archivos lateral
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle reveal<CR>", desc = "Explorador" },
    },
    opts = {
      window = { width = 32 },
      filesystem = {
        follow_current_file = { enabled = true },
        filtered_items = { hide_dotfiles = false, hide_gitignored = true },
      },
    },
  },

  -- Git: signos en el margen, blame y hunks
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Siguiente cambio")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Cambio anterior")
        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame línea")
        map("n", "<leader>gp", gs.preview_hunk, "Preview cambio")
      end,
    },
  },

  -- LazyGit en una ventana flotante
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" },
    },
  },

  -- Pares automáticos, surround y guía de indentación
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
      })
    end,
  },
}
