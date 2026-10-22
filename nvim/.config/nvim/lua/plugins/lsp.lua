return {
  -- Instalador de servidores LSP, linters y formatters
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
    },
  },

  -- Mason instala solo lo que necesitás
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "pyright",
        "ruff",
        "typescript-language-server",
        "prettier",
      },
    },
  },

  -- Autocompletado: LSP, rutas, snippets y buffer
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true },
        menu = { border = "rounded" },
      },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
    },
  },

  -- Configuración de servidores LSP (vim.lsp.config / vim.lsp.enable)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Capacidades que anuncia blink.cmp a todos los servidores
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })

      vim.lsp.enable({ "lua_ls", "pyright", "ruff", "ts_ls" })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded" },
        virtual_text = { spacing = 2, prefix = "●" },
      })

      -- Atajos que solo existen cuando un LSP está activo en el buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
        callback = function(event)
          local function map(l, r, desc)
            vim.keymap.set("n", l, r, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Ir a definición")
          map("gD", vim.lsp.buf.declaration, "Ir a declaración")
          map("gr", vim.lsp.buf.references, "Referencias")
          map("gi", vim.lsp.buf.implementation, "Implementaciones")
          map("K", vim.lsp.buf.hover, "Documentación")
          map("<leader>ca", vim.lsp.buf.code_action, "Acciones de código")
          map("<leader>cr", vim.lsp.buf.rename, "Renombrar")
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Siguiente diagnóstico")
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnóstico anterior")
        end,
      })
    end,
  },

  -- Formateo al guardar
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        desc = "Formatear",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
    },
  },
}
