-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ─────────────────────────────────────────
-- Cmd Keybindings (via Ghostty escape sequences)
-- ─────────────────────────────────────────

-- Cmd+s = Save
map({ "n", "i", "v" }, "<M-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "n", "i", "v" }, "\x1b[27;6;115~", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Cmd+z = Undo
map({ "n", "i" }, "\x1b[27;6;122~", "<cmd>undo<cr>", { desc = "Undo" })

-- Cmd+shift+z = Redo
map({ "n", "i" }, "\x1b[27;6;90~", "<cmd>redo<cr>", { desc = "Redo" })

-- Cmd+/ = Comment toggle (using Comment.nvim or native)
map("n", "\x1b[27;6;47~", "gcc", { desc = "Toggle comment", remap = true })
map("v", "\x1b[27;6;47~", "gc", { desc = "Toggle comment", remap = true })

-- Cmd+p = Find files (Telescope)
map("n", "\x1b[27;6;112~", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

-- Cmd+shift+p = Command palette
map("n", "\x1b[27;6;80~", "<cmd>Telescope commands<cr>", { desc = "Command palette" })

-- Cmd+b = Toggle file explorer (Neo-tree)
map({ "n", "i", "v", "t" }, "\x1b[27;6;98~", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
map({ "n", "i", "v", "t" }, "<D-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })
map({ "n", "i", "v", "t" }, "<M-b>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file explorer" })

-- Cmd+j/k/l = Navigate panes
map("n", "\x1b[27;6;106~", "<C-w>j", { desc = "Navigate down" })
map("n", "\x1b[27;6;107~", "<C-w>k", { desc = "Navigate up" })
map("n", "\x1b[27;6;108~", "<C-w>l", { desc = "Navigate right" })

-- Cmd+n = New buffer
map("n", "\x1b[27;6;110~", "<cmd>enew<cr>", { desc = "New buffer" })

-- Cmd+o = Open file
map("n", "\x1b[27;6;111~", "<cmd>Telescope find_files<cr>", { desc = "Open file" })

-- Cmd+, = Open config
map("n", "\x1b[27;6;44~", "<cmd>e ~/.config/nvim/init.lua<cr>", { desc = "Open config" })

-- ─────────────────────────────────────────
-- Insert Mode Shortcuts (Mac-style editing)
-- ─────────────────────────────────────────

-- Option+Backspace = Delete word backwards (like Ctrl-W)
map("i", "<M-BS>", "<C-W>", { desc = "Delete word backwards" })
map("c", "<M-BS>", "<C-W>", { desc = "Delete word backwards" })
-- Also map the common terminal escape sequence for Option+Backspace
map("i", "<A-BS>", "<C-W>", { desc = "Delete word backwards" })

-- Cmd+Backspace = Delete to beginning of line (like Ctrl-U)
map("i", "<D-BS>", "<C-U>", { desc = "Delete to beginning of line" })
-- Ghostty escape sequence for Cmd+Backspace (Super+Backspace)
map("i", "\x1b[127;6u", "<C-U>", { desc = "Delete to beginning of line" })

-- Option+Delete (forward delete word) - delete word forwards
map("i", "<M-Del>", "<C-o>dw", { desc = "Delete word forwards" })
map("i", "<A-Del>", "<C-o>dw", { desc = "Delete word forwards" })

-- Cmd+Delete (forward) = Delete to end of line
map("i", "<D-Del>", "<C-o>D", { desc = "Delete to end of line" })

-- Option+Left/Right = Move by word
map("i", "<M-Left>", "<C-o>b", { desc = "Move word left" })
map("i", "<M-Right>", "<C-o>w", { desc = "Move word right" })
map("i", "<A-Left>", "<C-o>b", { desc = "Move word left" })
map("i", "<A-Right>", "<C-o>w", { desc = "Move word right" })
-- Terminal escape sequences for Option+Arrow (ESC+b and ESC+f)
map("i", "\x1bb", "<C-o>b", { desc = "Move word left" })
map("i", "\x1bf", "<C-o>w", { desc = "Move word right" })
-- Also add for normal and visual mode
map({ "n", "v" }, "<M-Left>", "b", { desc = "Move word left" })
map({ "n", "v" }, "<M-Right>", "w", { desc = "Move word right" })
map({ "n", "v" }, "<A-Left>", "b", { desc = "Move word left" })
map({ "n", "v" }, "<A-Right>", "w", { desc = "Move word right" })
map({ "n", "v" }, "\x1bb", "b", { desc = "Move word left" })
map({ "n", "v" }, "\x1bf", "w", { desc = "Move word right" })

-- Cmd+Left/Right = Move to beginning/end of line
map("i", "<D-Left>", "<Home>", { desc = "Move to beginning of line" })
map("i", "<D-Right>", "<End>", { desc = "Move to end of line" })

-- ─────────────────────────────────────────
-- Better defaults
-- ─────────────────────────────────────────

-- Navigate windows with Ctrl+h/j/k/l (handled by tmux-navigator plugin)

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
