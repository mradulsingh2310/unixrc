-- Auto-save plugin configuration
-- Using okuuva/auto-save.nvim (actively maintained fork)
return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      -- Don't save if buffer is not modifiable or is readonly
      condition = function(buf)
        local fn = vim.fn
        local utils = require("auto-save.utils.data")

        if fn.getbufvar(buf, "&modifiable") == 1 and utils.not_in(fn.getbufvar(buf, "&filetype"), {}) then
          return true
        end
        return false
      end,
      write_all_buffers = false,
      -- Debounce delay in milliseconds
      debounce_delay = 1000,
      -- Don't show notification on save
      noautocmd = false,
      lockmarks = false,
      -- Callbacks
      callbacks = {
        before_saving = function()
          -- You can add custom logic here
        end,
        after_saving = function()
          -- You can add custom logic here
        end,
      },
    },
    keys = {
      { "<leader>ua", "<cmd>ASToggle<CR>", desc = "Toggle auto-save" },
    },
  },
}
