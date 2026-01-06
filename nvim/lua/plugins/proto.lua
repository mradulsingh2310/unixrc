return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure buf LSP (official buf lsp serve)
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Register buf_ls with lspconfig
      local configs = require("lspconfig.configs")
      if not configs.buf_ls then
        configs.buf_ls = {
          default_config = {
            cmd = { "buf", "lsp", "serve" },
            filetypes = { "proto" },
            root_dir = require("lspconfig.util").root_pattern("buf.yaml", ".git"),
          },
        }
      end

      return {
        servers = {
          buf_ls = {},
        },
      }
    end,
  },
}
