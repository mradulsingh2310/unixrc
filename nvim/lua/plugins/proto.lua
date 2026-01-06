-- Official buf LSP setup from https://buf.build/docs/cli/editors-lsp/
return {
  -- Add proto treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Setup buf_ls using native Neovim LSP API
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Register buf_ls as an LSP server
      vim.lsp.config("buf_ls", {
        cmd = { "buf", "lsp", "serve" },
        filetypes = { "proto" },
        root_markers = { "buf.yaml", ".git" },
      })
      -- Enable buf_ls
      vim.lsp.enable("buf_ls")
    end,
  },
}
