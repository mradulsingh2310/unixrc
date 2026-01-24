-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ─────────────────────────────────────────
-- Cmd Keybindings (using standard Neovim notation only)
-- Escape sequences REMOVED - they break Telescope input
-- ─────────────────────────────────────────

-- Cmd+s = Save (only <M-s>, no escape sequences)
map({ "n", "v" }, "<M-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Cmd+p = Find files (only standard keys)
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

-- ─────────────────────────────────────────
-- Insert Mode Shortcuts (Mac-style editing)
-- Using only standard Neovim notation, NO raw escape sequences
-- ─────────────────────────────────────────

-- Option+Backspace = Delete word backwards (like Ctrl-W)
map("i", "<M-BS>", "<C-W>", { desc = "Delete word backwards" })
map("c", "<M-BS>", "<C-W>", { desc = "Delete word backwards" })

-- Option+Left/Right = Move by word (standard notation only)
map("i", "<M-Left>", "<C-o>b", { desc = "Move word left" })
map("i", "<M-Right>", "<C-o>w", { desc = "Move word right" })
map({ "n", "v" }, "<M-Left>", "b", { desc = "Move word left" })
map({ "n", "v" }, "<M-Right>", "w", { desc = "Move word right" })

-- ─────────────────────────────────────────
-- Better defaults
-- ─────────────────────────────────────────

-- Resize windows with Ctrl+Arrow
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ─────────────────────────────────────────
-- Quickfix
-- ─────────────────────────────────────────
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix" })
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Open quickfix" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Close quickfix" })
map("n", "<leader>qx", "<cmd>cexpr []<cr>", { desc = "Clear quickfix" })

-- Delete quickfix entry with dd
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "dd", function()
      local idx = vim.fn.line(".")
      local qflist = vim.fn.getqflist()
      table.remove(qflist, idx)
      vim.fn.setqflist(qflist)
    end, { buffer = true, desc = "Delete quickfix entry" })
  end,
})
