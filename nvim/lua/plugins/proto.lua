return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure protols LSP with buf integration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        protols = {
          -- Function to find include paths for buf-based projects
          on_new_config = function(new_config, root_dir)
            local include_paths = {}

            -- Find buf.yaml to determine proto root
            local buf_yaml = vim.fn.findfile("buf.yaml", root_dir .. ";")
            if buf_yaml ~= "" then
              local buf_dir = vim.fn.fnamemodify(buf_yaml, ":h")

              -- Check for modules config in buf.yaml (v2 format has path: proto)
              local proto_root = buf_dir .. "/proto"
              if vim.fn.isdirectory(proto_root) == 1 then
                table.insert(include_paths, proto_root)
              else
                table.insert(include_paths, buf_dir)
              end

              -- Add buf cache paths for external dependencies
              local buf_cache = vim.fn.expand("~/.cache/buf/v3/modules/b5/buf.build")
              if vim.fn.isdirectory(buf_cache) == 1 then
                -- Add all cached module files directories
                local modules = {
                  "bufbuild/protovalidate",
                  "bufbuild/confluent",
                  "googleapis/googleapis",
                }
                for _, mod in ipairs(modules) do
                  local mod_path = buf_cache .. "/" .. mod
                  if vim.fn.isdirectory(mod_path) == 1 then
                    -- Find the latest commit directory
                    local handle = io.popen("ls -t " .. vim.fn.shellescape(mod_path) .. " 2>/dev/null | head -1")
                    if handle then
                      local commit = handle:read("*l")
                      handle:close()
                      if commit and commit ~= "" then
                        local files_path = mod_path .. "/" .. commit .. "/files"
                        if vim.fn.isdirectory(files_path) == 1 then
                          table.insert(include_paths, files_path)
                        end
                      end
                    end
                  end
                end
              end
            end

            -- Build cmd args with include paths
            if #include_paths > 0 then
              new_config.cmd = { "protols" }
              for _, path in ipairs(include_paths) do
                table.insert(new_config.cmd, "--include-paths")
                table.insert(new_config.cmd, path)
              end
            end
          end,
        },
      },
    },
  },

  -- Install protols via Mason
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "protols" })
    end,
  },
}
