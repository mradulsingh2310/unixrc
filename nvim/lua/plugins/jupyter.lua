-- Jupyter Notebook Setup (minimal - without image.nvim for now)

return {
  -- Jupytext: Convert .ipynb <-> markdown
  {
    "goerz/jupytext.nvim",
    version = "0.2",
    lazy = false,
    opts = {
      format = "py:percent", -- Python with # %% markers (faster than md)
      update = true,
    },
  },

  -- Molten: Run code with Jupyter kernels
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
    end,
    cmd = { "MoltenInit", "MoltenEvaluateLine" },
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", desc = "Eval visual", mode = "v" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Run cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
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
