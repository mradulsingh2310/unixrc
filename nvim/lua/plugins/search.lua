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
    vim.api.nvim_set_hl(0, "FzfLuaTitle", { bg = base, fg = text })

    -- Force winblend=0 on all fzf-lua floating windows
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fzf",
      callback = function()
        vim.wo.winblend = 0
      end,
    })

    opts = vim.tbl_deep_extend("force", opts, {
      fzf_colors = {
        ["bg"] = { "bg", "FzfLuaNormal" },
        ["bg+"] = { "bg", "FzfLuaCursorLine" },
        ["fg"] = { "fg", "FzfLuaNormal" },
        ["fg+"] = { "fg", "FzfLuaNormal" },
        ["hl"] = { "fg", "Comment" },
        ["hl+"] = { "fg", "Statement" },
        ["info"] = { "fg", "Comment" },
        ["prompt"] = { "fg", "Function" },
        ["pointer"] = { "fg", "Statement" },
        ["marker"] = { "fg", "Statement" },
        ["header"] = { "fg", "Comment" },
        ["gutter"] = { "bg", "FzfLuaNormal" },
      },
      winopts = {
        height = 0.8,
        width = 0.8,
        winblend = 0,
        preview = {
          winblend = 0,
        },
        hl = {
          normal = "FzfLuaNormal",
          border = "FzfLuaBorder",
          title = "FzfLuaTitle",
          preview_normal = "FzfLuaPreviewNormal",
          preview_border = "FzfLuaPreviewBorder",
          preview_title = "FzfLuaTitle",
          cursor = "FzfLuaCursorLine",
          cursorline = "FzfLuaCursorLine",
        },
      },
    })

    require("fzf-lua").setup(opts)
  end,
}
