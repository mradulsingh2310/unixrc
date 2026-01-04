return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      enabled = false,
    },
    messages = {
      enabled = false,
    },
  },
  init = function()
    vim.opt.cmdheight = 1
  end,
}
