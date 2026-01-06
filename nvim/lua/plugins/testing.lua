-- Testing configuration
-- Keybindings:
--   Ctrl+Shift+T: Run test (then press 'd' for debug mode)
--   Ctrl+Shift+B: Toggle breakpoint

-- NOTE: neotest-java disabled due to startup assertion error
-- To re-enable later, run :NeotestJava setup first

return {
  -- Ctrl+Shift keybindings only (no neotest for now)
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Ctrl+Shift+T: Run Maven test via terminal
          vim.keymap.set({ "n", "i" }, "\x1b[116;6u", function()
            vim.cmd("stopinsert")
            vim.api.nvim_echo({ { "[t]est  [d]ebug", "Question" } }, false, {})
            local char = vim.fn.getcharstr()
            vim.cmd("redraw")

            -- Get current file and derive test class
            local file = vim.fn.expand("%:p")
            local test_class = nil

            -- If in main, find corresponding test
            if file:match("/main/java/") then
              local class_name = vim.fn.expand("%:t:r")
              test_class = class_name .. "Test"
            elseif file:match("/test/java/") then
              test_class = vim.fn.expand("%:t:r")
            end

            if test_class then
              local cmd = "mvn test -Dtest=" .. test_class
              if char == "d" then
                cmd = cmd .. " -Dmaven.surefire.debug"
              end
              -- Open terminal in horizontal split at bottom
              vim.cmd("botright split | resize 15 | terminal " .. cmd)
            else
              vim.notify("Not in a Java source/test file", vim.log.levels.WARN)
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
