-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local zeus_path = "/Users/mradulsingh/zeus_backend/zeus"

-- ─────────────────────────────────────────
-- Zeus Backend: Format with Spotless on save
-- ─────────────────────────────────────────
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  callback = function()
    local filepath = vim.fn.expand("%:p")

    -- Only run for files in zeus backend
    if not filepath:find(zeus_path, 1, true) then
      return
    end

    -- Run spotless:apply asynchronously
    vim.fn.jobstart({ "mvn", "spotless:apply", "-f", zeus_path .. "/pom.xml" }, {
      cwd = zeus_path,
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          -- Reload the buffer to show formatted content
          vim.schedule(function()
            local bufnr = vim.fn.bufnr(filepath)
            if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
              vim.api.nvim_buf_call(bufnr, function()
                vim.cmd("checktime")
              end)
            end
          end)
        end
      end,
      stdout_buffered = true,
      stderr_buffered = true,
    })
  end,
  desc = "Run mvn spotless:apply for zeus backend files",
})
