-- Jupyter Notebook Setup (from Reddit: molten + quarto + jupytext + image.nvim)
-- Open .ipynb -> auto-converts to markdown -> edit with LSP -> run with molten -> save back to .ipynb

return {
  -- 1. Jupytext: Auto-convert .ipynb <-> markdown on open/save
  {
    "goerz/jupytext.nvim",
    version = "0.2",
    opts = {
      format = "md", -- Convert to markdown (works best with quarto)
      update = true, -- Preserve outputs
      autosync = true,
    },
  },

  -- 2. Molten: Run code with Jupyter kernels, show output inline
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_wrap_output = true
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Eval line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", desc = "Eval visual", mode = "v" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Run cell" },
      { "<leader>jo", "<cmd>MoltenShowOutput<cr>", desc = "Show output" },
      { "<leader>jh", "<cmd>MoltenHideOutput<cr>", desc = "Hide output" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Delete output" },
      { "<leader>jx", "<cmd>MoltenInterrupt<cr>", desc = "Interrupt kernel" },
    },
  },

  -- 3. Image.nvim: Render images (plots, charts) inline
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty", -- Use "kitty" or "ueberzug"
      integrations = {
        markdown = { enabled = true, clear_in_insert_mode = true },
      },
      max_width = 100,
      max_height = 12,
      window_overlap_clear_enabled = true,
    },
  },

  -- 4. Quarto: LSP features (autocomplete, diagnostics) in code cells
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    config = function()
      require("quarto").setup({
        lspFeatures = {
          enabled = true,
          languages = { "python" },
          chunks = "all",
          diagnostics = { enabled = true, triggers = { "BufWritePost" } },
          completion = { enabled = true },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      })

      -- Auto-activate quarto for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          require("quarto").activate()
        end,
      })
    end,
    keys = {
      { "<leader>jR", function() require("quarto.runner").run_cell() end, desc = "Run cell (quarto)" },
      { "<leader>ja", function() require("quarto.runner").run_above() end, desc = "Run cells above" },
      { "<leader>jA", function() require("quarto.runner").run_all() end, desc = "Run all cells" },
    },
  },

  -- 5. Otter: LSP for embedded code (dependency of quarto)
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
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
