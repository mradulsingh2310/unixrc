-- Jupyter Notebook Support
-- Two modes:
-- 1. jupytext.nvim: Open .ipynb files as readable Python/Markdown (native editing)
-- 2. Jupynium: Full browser-synced notebook experience with execution

return {
  -- jupytext.nvim: Native .ipynb viewing/editing
  -- Opens notebooks as readable text format, auto-saves back to .ipynb
  {
    "goerz/jupytext.nvim",
    version = "0.2",
    opts = {
      format = "py:percent", -- Convert to Python with # %% cell markers
      update = true, -- Preserve outputs when saving
      autosync = true, -- Auto-sync paired files
    },
  },

  -- Jupynium: Browser-synced notebook (for execution)
  {
    "kiyoon/jupynium.nvim",
    build = "uv tool install . --force",
    dependencies = {
      "stevearc/dressing.nvim",
    },
    config = function()
      require("jupynium").setup({
        python_host = vim.g.python3_host_prog or "python3",
        default_notebook_URL = "localhost:8888/nbclassic",
        jupyter_command = "jupyter",

        auto_start_server = { enable = false, file_pattern = { "*.ju.py" } },
        auto_attach_to_server = { enable = true, file_pattern = { "*.ju.py" } },
        auto_start_sync = { enable = false, file_pattern = { "*.ju.py" } },
        auto_download_ipynb = true,
        auto_close_tab = true,

        autoscroll = { enable = true, mode = "always" },
        use_default_keybindings = true,
        textobjects = { use_default_keybindings = true },
        syntax_highlight = { enable = true },
        shortsighted = false,
      })
    end,
    keys = {
      { "<leader>js", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Start Jupynium" },
      { "<leader>jS", "<cmd>JupyniumStartSync<cr>", desc = "Sync to notebook" },
      { "<leader>jx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Execute cell", mode = { "n", "x" } },
      { "<leader>jX", "<cmd>JupyniumExecuteSelectedCells<cr><cmd>JupyniumScrollToCell<cr>", desc = "Execute & scroll" },
      { "<leader>jc", "<cmd>JupyniumClearSelectedCellsOutputs<cr>", desc = "Clear outputs", mode = { "n", "x" } },
      { "<leader>jK", "<cmd>JupyniumKernelRestart<cr>", desc = "Restart kernel" },
      { "<leader>jI", "<cmd>JupyniumKernelInterrupt<cr>", desc = "Interrupt kernel" },
      { "<leader>jw", "<cmd>JupyniumSaveIpynb<cr>", desc = "Save .ipynb" },
      { "<leader>jd", "<cmd>JupyniumStopSync<cr>", desc = "Stop sync" },
    },
    ft = { "python" },
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
