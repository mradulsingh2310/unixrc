-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use Telescope instead of fzf-lua
vim.g.lazyvim_picker = "telescope"

local opt = vim.opt

-- UI
opt.termguicolors = true -- True color support
opt.cursorline = true -- Enable highlighting of the current line
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.signcolumn = "yes" -- Always show the signcolumn
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.winblend = 10 -- Window blend

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.autoindent = true -- Copy indent from current line when starting new line
opt.smartindent = true -- Insert indents automatically
opt.copyindent = true -- Copy the structure of existing indent
opt.preserveindent = true -- Preserve indent structure when reindenting
opt.cindent = true -- C-style indentation (better for Java/C/C++)

-- Search
opt.ignorecase = true -- Ignore case
opt.smartcase = true -- Don't ignore case with capitals
opt.hlsearch = true -- Highlight search results

-- Misc
opt.scrolloff = 8 -- Lines of context
opt.sidescrolloff = 8 -- Columns of context
opt.wrap = false -- Disable line wrap
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.undofile = true -- Enable persistent undo
opt.updatetime = 200 -- Save swap file and trigger CursorHold

-- Statusline at bottom with no gap
opt.cmdheight = 0 -- Hide command line when not in use
opt.laststatus = 3 -- Global statusline
