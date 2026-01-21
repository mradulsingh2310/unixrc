-- Jupyter Notebook Support with Molten
-- Run code cells, view outputs inline, image support

return {
  -- Molten: Execute code with Jupyter kernels
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "3rd/image.nvim", -- For image output
    },
    init = function()
      -- Molten settings
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", desc = "Eval visual", mode = "v" },
      { "<leader>jc", "<cmd>MoltenReevaluateCell<cr>", desc = "Eval cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete cell" },
    },
  },

  -- Image rendering (for plot outputs)
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- or "ueberzug" for X11
      integrations = {
        markdown = { enabled = true },
      },
      max_width = 100,
      max_height = 12,
      window_overlap_clear_enabled = true,
    },
  },

  -- Quarto for notebook editing + LSP in code cells
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "python" },
        chunks = "all",
        diagnostics = { enabled = true },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    keys = {
      { "<leader>jq", "<cmd>QuartoPreview<cr>", desc = "Quarto preview" },
      { "<leader>jr", "<cmd>QuartoSendAbove<cr>", desc = "Run cells above" },
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
