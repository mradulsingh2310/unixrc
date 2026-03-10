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

    -- Force winblend=0 on the main fzf picker window (filetype = "fzf")
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fzf",
      callback = function()
        vim.wo.winblend = 0
      end,
    })

    -- Force winblend=0 on the preview window.
    -- The preview window has the filetype of the previewed file (not "fzf"),
    -- so the FileType autocmd above never fires for it. Instead we hook WinNew
    -- and use vim.schedule (runs after fzf-lua finishes setting winhighlight)
    -- to find every floating window whose winhighlight contains "FzfLua" and
    -- set winblend=0 there.
    vim.api.nvim_create_autocmd("WinNew", {
      callback = function()
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local ok, whl = pcall(vim.api.nvim_win_get_option, win, "winhighlight")
            if ok and whl and whl:find("FzfLua") then
              pcall(vim.api.nvim_win_set_option, win, "winblend", 0)
            end
          end
        end)
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
