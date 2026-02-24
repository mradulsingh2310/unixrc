return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<C-p>", "<cmd>FzfLua files<cr>", desc = "Find Files" },
  },
  config = function(_, opts)
    -- Catppuccin mocha palette colors for opaque fzf-lua windows
    local base = "#1e1e2e"
    local mantle = "#181825"
    local text = "#cdd6f4"
    local surface2 = "#585b70"

    vim.api.nvim_set_hl(0, "FzfLuaNormal", { bg = base, fg = text })
    vim.api.nvim_set_hl(0, "FzfLuaBorder", { bg = base, fg = surface2 })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewNormal", { bg = mantle, fg = text })
    vim.api.nvim_set_hl(0, "FzfLuaPreviewBorder", { bg = mantle, fg = surface2 })
    vim.api.nvim_set_hl(0, "FzfLuaCursorLine", { bg = "#313244" })

    opts = vim.tbl_deep_extend("force", opts, {
      winopts = {
        height = 0.8,
        width = 0.8,
        treesitter = { enabled = false },
        preview = {
          winopts = { winblend = 0 },
        },
        winblend = 0,
        hl = {
          normal = "FzfLuaNormal",
          border = "FzfLuaBorder",
          cursor = "FzfLuaCursorLine",
          cursorline = "FzfLuaCursorLine",
          preview_normal = "FzfLuaPreviewNormal",
          preview_border = "FzfLuaPreviewBorder",
        },
      },
    })

    require("fzf-lua").setup(opts)
  end,
}
