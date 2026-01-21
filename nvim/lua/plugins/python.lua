-- Python Development Configuration
return {
  -- Configure Ruff LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff = {
          init_options = {
            settings = {
              lineLength = 100,
            },
          },
        },
      },
    },
  },

  -- Conform for formatting (uses Ruff)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
