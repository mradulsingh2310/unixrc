return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure protols LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        protols = {},
      },
    },
  },

  -- Install protols via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "protols" })
    end,
  },
}
