-- Jupyter Notebook Support with Jupynium
-- Selenium-based real-time sync between Neovim and Jupyter Notebook

return {
  {
    "kiyoon/jupynium.nvim",
    -- Use uv to install in isolated environment (no system Python modification)
    build = "uv tool install . --force",
    dependencies = {
      "rcarriga/nvim-notify", -- Optional: for notifications
      "stevearc/dressing.nvim", -- Optional: for better UI
    },
    config = function()
      require("jupynium").setup({
        -- Python executable to use
        python_host = vim.g.python3_host_prog or "python3",

        -- Default Jupyter URL (use nbclassic for Notebook 7+)
        default_notebook_URL = "localhost:8888/nbclassic",

        -- Browser settings
        jupyter_command = "jupyter",
        notebook_dir = nil, -- Uses current directory

        -- Firefox is required for Selenium
        firefox_profiles_ini_path = nil, -- Auto-detect
        firefox_profile_name = nil, -- Use default profile

        -- Auto behaviors
        auto_start_server = {
          enable = false,
          file_pattern = { "*.ju.py", "*.ju.lua" },
        },
        auto_attach_to_server = {
          enable = true,
          file_pattern = { "*.ju.py", "*.ju.lua" },
        },
        auto_start_sync = {
          enable = false,
          file_pattern = { "*.ju.py", "*.ju.lua" },
        },
        auto_download_ipynb = true,
        auto_close_tab = true,

        -- Scroll behavior
        autoscroll = {
          enable = true,
          mode = "always", -- "always", "invisible"
          cell = {
            top_margin_percent = 20,
          },
        },

        -- Cell markers
        scroll = {
          page = { step = 0.5 },
          cell = {
            top_margin_percent = 20,
          },
        },

        -- Use the short_name in vim syntax list
        use_default_keybindings = true,
        textobjects = {
          use_default_keybindings = true,
        },

        -- Syntax highlighting
        syntax_highlight = {
          enable = true,
        },

        -- Cell separator
        -- You can use any string that doesn't conflict with your code
        -- Default: "# %%"
        shortsighted = false,

        -- Kernel info
        kernel_hover = {
          enable = true,
          delay_ms = 1000,
        },
      })

      -- Set up keymaps for Jupynium
      local jupynium = require("jupynium.textobj")

      vim.keymap.set(
        { "n", "x", "o" },
        "[j",
        function() jupynium.goto_previous_cell_separator() end,
        { desc = "Go to previous cell" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "]j",
        function() jupynium.goto_next_cell_separator() end,
        { desc = "Go to next cell" }
      )
      vim.keymap.set(
        { "x", "o" },
        "aj",
        function() jupynium.select_cell(true, false) end,
        { desc = "Select around cell" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ij",
        function() jupynium.select_cell(false, false) end,
        { desc = "Select inside cell" }
      )
    end,
    keys = {
      -- Server management
      { "<leader>js", "<cmd>JupyniumStartAndAttachToServer<cr>", desc = "Start Jupynium server" },
      { "<leader>jS", "<cmd>JupyniumStartSync<cr>", desc = "Start sync (create notebook)" },
      { "<leader>ja", "<cmd>JupyniumAttachToServer<cr>", desc = "Attach to server" },
      { "<leader>jd", "<cmd>JupyniumStopSync<cr>", desc = "Stop sync" },

      -- Cell execution
      { "<leader>jx", "<cmd>JupyniumExecuteSelectedCells<cr>", desc = "Execute selected cells", mode = { "n", "x" } },
      { "<leader>jc", "<cmd>JupyniumClearSelectedCellsOutputs<cr>", desc = "Clear cell outputs", mode = { "n", "x" } },
      { "<leader>jX", "<cmd>JupyniumExecuteSelectedCells<cr><cmd>JupyniumScrollToCell<cr>", desc = "Execute and scroll" },

      -- Kernel management
      { "<leader>jK", "<cmd>JupyniumKernelRestart<cr>", desc = "Restart kernel" },
      { "<leader>jI", "<cmd>JupyniumKernelInterrupt<cr>", desc = "Interrupt kernel" },
      { "<leader>jH", "<cmd>JupyniumKernelHover<cr>", desc = "Hover (show kernel info)" },

      -- Notebook management
      { "<leader>jo", "<cmd>JupyniumLoadFromIpynbTab<cr>", desc = "Load from .ipynb" },
      { "<leader>jw", "<cmd>JupyniumSaveIpynb<cr>", desc = "Save as .ipynb" },

      -- Navigation
      { "<leader>jn", "<cmd>JupyniumScrollToCell<cr>", desc = "Scroll to current cell" },
      { "<leader>jt", "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>", desc = "Toggle output scroll" },
    },
  },

  -- Add which-key group for Jupyter
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>j", group = "jupyter", icon = "" },
      },
    },
  },

  -- Optional: nvim-cmp source for Jupyter kernel completions
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    opts = function(_, opts)
      local ok, cmp = pcall(require, "cmp")
      if not ok then return end

      -- Check if jupynium cmp source exists
      local jupynium_ok, _ = pcall(require, "jupynium.cmp")
      if jupynium_ok then
        opts.sources = opts.sources or {}
        table.insert(opts.sources, { name = "jupynium", priority = 1000 })
      end
    end,
  },
}
