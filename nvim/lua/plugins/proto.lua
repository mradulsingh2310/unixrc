return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure protols LSP (uses .protols.toml in project root for include paths)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        protols = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".protols.toml", "buf.yaml", "buf.work.yaml", ".git")(fname)
          end,
        },
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
