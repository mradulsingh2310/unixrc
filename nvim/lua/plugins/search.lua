return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
  },
  opts = {
    defaults = {
      winblend = 0,
    },
  },
}
