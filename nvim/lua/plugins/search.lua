return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find Files" },
  },
  opts = {
    defaults = {
      winopts = {
        height = 0.8,
        width = 0.8,
      },
    },
  },
}
