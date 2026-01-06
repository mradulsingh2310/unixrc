-- Testing configuration with neotest for Java (and Python)
-- Keybindings:
--   Ctrl+Shift+T: Run test (then press 'd' for debug mode)
--   Ctrl+Shift+B: Toggle breakpoint

return {
  -- Neotest with adapters
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adapters
      "rcasia/neotest-java",
      "nvim-neotest/neotest-python",
    },
    opts = function()
      return {
        -- Output panel at bottom (horizontal split inside Neovim)
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        status = {
          virtual_text = true,
          signs = true,
        },
        output = {
          enabled = true,
          open_on_run = false,
        },
        summary = {
          enabled = true,
          open = "botright vsplit | vertical resize 40",
        },
        -- Adapters
        adapters = {
          require("neotest-java")({
            ignore_wrapper = false,
          }),
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
        },
      }
    end,
    keys = {
      { "<leader>tr", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Tests" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last Test" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop Test" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest Test" },
    },
  },

  -- Ctrl+Shift keybindings (set up after plugins load)
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Ctrl+Shift+T: Test menu
          vim.keymap.set({ "n", "i" }, "\x1b[116;6u", function()
            vim.cmd("stopinsert")
            vim.api.nvim_echo({ { "[t]est  [d]ebug", "Question" } }, false, {})
            local char = vim.fn.getcharstr()
            vim.cmd("redraw")

            if char == "d" then
              require("neotest").output_panel.open()
              require("neotest").run.run({ strategy = "dap" })
            else
              require("neotest").output_panel.open()
              require("neotest").run.run()
            end
          end, { desc = "Test: [t]est [d]ebug" })

          -- Ctrl+Shift+B: Toggle breakpoint
          vim.keymap.set({ "n", "i" }, "\x1b[98;6u", function()
            vim.cmd("stopinsert")
            require("dap").toggle_breakpoint()
            vim.notify("Breakpoint toggled", vim.log.levels.INFO)
          end, { desc = "Toggle Breakpoint" })
        end,
      })
      return opts
    end,
  },
}
