-- Testing configuration with neotest for Java (and Python)
-- Keybindings:
--   Ctrl+Shift+T: Run test for current file (opens in horizontal split)
--   Ctrl+Shift+B: Toggle breakpoint
--   Ctrl+Shift+D: Run test in debug mode

-- Helper function to find corresponding test file for a source file
local function find_test_file()
  local current_file = vim.fn.expand("%:p")
  local current_name = vim.fn.expand("%:t:r") -- filename without extension

  -- For Java files: MyClass.java -> MyClassTest.java
  if current_file:match("%.java$") then
    -- Check if already in a test file
    if current_file:match("Test%.java$") or current_file:match("/test/") then
      return current_file
    end

    -- Convert src/main/java/... to src/test/java/...Test.java
    local test_file = current_file:gsub("/main/", "/test/"):gsub("%.java$", "Test.java")
    if vim.fn.filereadable(test_file) == 1 then
      return test_file
    end

    -- Try *Tests.java variant
    test_file = current_file:gsub("/main/", "/test/"):gsub("%.java$", "Tests.java")
    if vim.fn.filereadable(test_file) == 1 then
      return test_file
    end
  end

  -- For Python files: my_module.py -> test_my_module.py or my_module_test.py
  if current_file:match("%.py$") then
    if current_file:match("test_") or current_file:match("_test%.py$") then
      return current_file
    end

    -- Try test_ prefix in tests/ directory
    local dir = vim.fn.expand("%:p:h")
    local test_dir = dir:gsub("/src/", "/tests/"):gsub("/lib/", "/tests/")
    local test_file = test_dir .. "/test_" .. current_name .. ".py"
    if vim.fn.filereadable(test_file) == 1 then
      return test_file
    end

    -- Try _test suffix
    test_file = test_dir .. "/" .. current_name .. "_test.py"
    if vim.fn.filereadable(test_file) == 1 then
      return test_file
    end
  end

  return current_file
end

-- Function to run test in horizontal split
local function run_test_in_split()
  local test_file = find_test_file()
  local current_file = vim.fn.expand("%:p")

  -- If we found a different test file, open it first
  if test_file ~= current_file then
    -- Open test file in horizontal split below
    vim.cmd("botright split " .. vim.fn.fnameescape(test_file))
  end

  -- Run the test using neotest
  require("neotest").run.run(test_file)

  -- Open output panel in horizontal split
  require("neotest").output_panel.open()
end

-- Function to run test in debug mode
local function run_test_debug()
  local test_file = find_test_file()
  local current_file = vim.fn.expand("%:p")

  -- If we found a different test file, open it first
  if test_file ~= current_file then
    vim.cmd("botright split " .. vim.fn.fnameescape(test_file))
  end

  -- Run the test with DAP strategy
  require("neotest").run.run({ test_file, strategy = "dap" })
end

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
      -- Configure output panel to open at bottom (horizontal)
      output_panel = {
        enabled = true,
        open = "botright split | resize 15",
      },
      -- Status signs in the gutter
      status = {
        virtual_text = true,
        signs = true,
      },
      -- Summary panel on the right
      summary = {
        open = "botright vsplit | vertical resize 50",
      },
      -- Floating output settings
      output = {
        enabled = true,
        open_on_run = false, -- We'll use the panel instead
      },
    },
    keys = {
      -- Override default keymaps to use our custom functions
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
        desc = "Run All Test Files",
      },
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest Test",
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
        desc = "Show Output",
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
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end,
        desc = "Toggle Watch",
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
    config = function()
      -- Add Java adapter to neotest
      require("neotest").setup({
        adapters = {
          require("neotest-java")({
            -- Use Maven or Gradle based on project
            junit_jar = nil, -- Auto-detect
            incremental_build = true,
          }),
        },
      })
    end,
  },

  -- Python test adapter (bonus)
  {
    "nvim-neotest/neotest-python",
    ft = "python",
    dependencies = {
      "nvim-neotest/neotest",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
        },
      })
    end,
  },

  -- DAP configuration for breakpoints
  {
    "mfussenegger/nvim-dap",
    keys = {
      -- Breakpoint keybindings with leader
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
      {
        "<leader>dl",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Log Point",
      },
    },
  },

  -- Custom keybindings for Ctrl+Shift combinations
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      -- Register our test keybindings with which-key
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local map = vim.keymap.set

          -- Ctrl+Shift+T: Run test for current file in horizontal split
          -- Standard terminal mapping
          map({ "n", "i" }, "<C-S-t>", function()
            vim.cmd("stopinsert")
            run_test_in_split()
          end, { desc = "Run Test (horizontal split)" })

          -- Ghostty CSI u encoding for Ctrl+Shift+T (modifier 6, keycode 116 for 't')
          map({ "n", "i" }, "\x1b[116;6u", function()
            vim.cmd("stopinsert")
            run_test_in_split()
          end, { desc = "Run Test (horizontal split)" })

          -- Alternative: xterm-style for Ctrl+Shift+T
          map({ "n", "i" }, "\x1b[27;6;116~", function()
            vim.cmd("stopinsert")
            run_test_in_split()
          end, { desc = "Run Test (horizontal split)" })

          -- Ctrl+Shift+B: Toggle breakpoint
          map({ "n", "i" }, "<C-S-b>", function()
            vim.cmd("stopinsert")
            require("dap").toggle_breakpoint()
          end, { desc = "Toggle Breakpoint" })

          -- Ghostty CSI u encoding for Ctrl+Shift+B
          map({ "n", "i" }, "\x1b[98;6u", function()
            vim.cmd("stopinsert")
            require("dap").toggle_breakpoint()
          end, { desc = "Toggle Breakpoint" })

          map({ "n", "i" }, "\x1b[27;6;98~", function()
            vim.cmd("stopinsert")
            require("dap").toggle_breakpoint()
          end, { desc = "Toggle Breakpoint" })

          -- Ctrl+Shift+D: Run test in debug mode
          map({ "n", "i" }, "<C-S-d>", function()
            vim.cmd("stopinsert")
            run_test_debug()
          end, { desc = "Debug Test" })

          -- Ghostty CSI u encoding for Ctrl+Shift+D
          map({ "n", "i" }, "\x1b[100;6u", function()
            vim.cmd("stopinsert")
            run_test_debug()
          end, { desc = "Debug Test" })

          map({ "n", "i" }, "\x1b[27;6;100~", function()
            vim.cmd("stopinsert")
            run_test_debug()
          end, { desc = "Debug Test" })
        end,
      })

      return opts
    end,
  },
}
