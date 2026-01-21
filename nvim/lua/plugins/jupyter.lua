-- Jupyter Notebook Setup
-- jupytext converts .ipynb to Python with # %% cell markers

return {
  -- Jupytext: Convert .ipynb <-> Python
  {
    "goerz/jupytext.nvim",
    version = "0.2",
    opts = {
      format = "py:percent",
      update = true,
    },
  },

  -- Molten: Run code with Jupyter kernels (lazy loaded)
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
    end,
    cmd = { "MoltenInit" },
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", desc = "Eval visual", mode = "v" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Run cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
    },
  },

  -- which-key
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>j", group = "jupyter" } } },
  },
}
