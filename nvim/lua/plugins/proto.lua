return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure pbls LSP (uses .pbls.toml in project root for proto_paths)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pbls = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(".pbls.toml", "buf.yaml", ".git")(fname)
          end,
        },
      },
    },
  },

  -- Install pbls via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pbls" })
    end,
  },
}
