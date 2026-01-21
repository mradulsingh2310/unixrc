-- Jupyter Notebook Support
-- nvim-jupyter-client: Fast native .ipynb editing (no external conversion)
-- Jupynium: Browser-synced execution (optional)

return {
  -- Native .ipynb editing - fast, no external tools needed
  {
    "geg2102/nvim-jupyter-client",
    ft = { "ipynb" },
    config = function()
      require("nvim-jupyter-client").setup({})
    end,
    keys = {
      { "<leader>ja", "<cmd>JupyterAddCellBelow<cr>", desc = "Add cell below", ft = "ipynb" },
      { "<leader>jA", "<cmd>JupyterAddCellAbove<cr>", desc = "Add cell above", ft = "ipynb" },
      { "<leader>jd", "<cmd>JupyterRemoveCell<cr>", desc = "Delete cell", ft = "ipynb" },
      { "<leader>jt", "<cmd>JupyterConvertCellType<cr>", desc = "Toggle cell type", ft = "ipynb" },
      { "<leader>jm", "<cmd>JupyterMergeCellBelow<cr>", desc = "Merge cell below", ft = "ipynb" },
      { "<leader>jM", "<cmd>JupyterMergeCellAbove<cr>", desc = "Merge cell above", ft = "ipynb" },
    },
  },

  -- Jupynium: For executing cells via browser (optional)
  {
    "kiyoon/jupynium.nvim",
    build = "uv tool install . --force",
    cmd = { "JupyniumStartAndAttachToServer", "JupyniumStartSync" },
    config = function()
      require("jupynium").setup({
        python_host = vim.g.python3_host_prog or "python3",
        default_notebook_URL = "localhost:8888/nbclassic",
        auto_download_ipynb = true,
        use_default_keybindings = true,
        textobjects = { use_default_keybindings = true },
      })
    end,
    keys = {
      { "<leader>js", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Start Jupynium" },
      { "<leader>jS", "<cmd>JupyniumStartSync<cr>", desc = "Sync to browser" },
      { "<leader>jx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Execute cell", mode = { "n", "x" } },
      { "<leader>jK", "<cmd>JupyniumKernelRestart<cr>", desc = "Restart kernel" },
      { "<leader>jI", "<cmd>JupyniumKernelInterrupt<cr>", desc = "Interrupt kernel" },
    },
  },

  -- which-key group
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "jupyter" },
      },
    },
  },
}
