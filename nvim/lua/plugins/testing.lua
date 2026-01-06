-- Testing configuration with neotest for Java (and Python)
-- Keybindings:
--   Ctrl+Shift+T: Run test (then press 'd' for debug mode)
--   Ctrl+Shift+B: Toggle breakpoint

return {
  -- Neotest core configuration
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- Output panel at bottom (horizontal split inside Neovim)
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },
      -- Status in gutter
      status = {
        virtual_text = true,
        signs = true,
      },
      -- Don't auto-open floating output
      output = {
        enabled = true,
        open_on_run = false,
      },
      -- Summary panel configuration
      summary = {
        enabled = true,
        open = "botright vsplit | vertical resize 40",
      },
    },
    keys = {
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest Test",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run File Tests",
      },
      {
        "<leader>tT",
        function()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "Run All Tests",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "Run Last Test",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "Toggle Summary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "Show Output (floating)",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "Toggle Output Panel",
      },
      {
        "<leader>tS",
        function()
          require("neotest").run.stop()
        end,
        desc = "Stop Test",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug Nearest Test",
      },
    },
  },

  -- Java test adapter
  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "mfussenegger/nvim-dap",
      "nvim-neotest/neotest",
    },
    opts = {
      junit_jar = nil,
      incremental_build = true,
    },
  },

  -- Python test adapter
  {
    "nvim-neotest/neotest-python",
    ft = "python",
    dependencies = {
      "nvim-neotest/neotest",
    },
    opts = {
      dap = { justMyCode = false },
      runner = "pytest",
    },
  },

  -- Configure adapters properly
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      -- Add adapters if available
      local ok_java, neotest_java = pcall(require, "neotest-java")
      if ok_java then
        table.insert(opts.adapters, neotest_java({ incremental_build = true }))
      end
      local ok_python, neotest_python = pcall(require, "neotest-python")
      if ok_python then
        table.insert(opts.adapters, neotest_python({ dap = { justMyCode = false } }))
      end
    end,
  },

  -- DAP for breakpoints
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Conditional Breakpoint",
      },
    },
  },

  -- Ctrl+Shift keybindings
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local map = vim.keymap.set

          -- Ctrl+Shift+T: Test menu
          -- Press Enter or any key = run test, press 'd' = debug test
          map({ "n", "i" }, "\x1b[116;6u", function()
            vim.cmd("stopinsert")
            vim.api.nvim_echo({ { "[t]est  [d]ebug", "Question" } }, false, {})

            local char = vim.fn.getcharstr()
            vim.cmd("redraw")

            if char == "d" then
              -- Debug: run with DAP and open output panel
              require("neotest").output_panel.open()
              require("neotest").run.run({ strategy = "dap" })
            else
              -- Run test and open output panel at bottom
              require("neotest").output_panel.open()
              require("neotest").run.run()
            end
          end, { desc = "Test: [t]est [d]ebug" })

          -- Ctrl+Shift+B: Toggle breakpoint
          map({ "n", "i" }, "\x1b[98;6u", function()
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
