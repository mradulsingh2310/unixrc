-- Helper to get buf include paths dynamically
local function get_buf_include_paths(root_dir)
  local paths = {}

  -- Add proto subdirectory if it exists (common buf v2 layout)
  local proto_dir = root_dir .. "/proto"
  if vim.fn.isdirectory(proto_dir) == 1 then
    table.insert(paths, proto_dir)
  end

  -- Parse buf.lock to find dependencies
  local buf_lock = root_dir .. "/buf.lock"
  local file = io.open(buf_lock, "r")
  if file then
    local content = file:read("*a")
    file:close()

    -- Extract dependency names
    local deps = {}
    for dep in content:gmatch("name:%s*(buf%.build/[%w_/-]+)") do
      table.insert(deps, dep)
    end

    -- Find buf cache
    local cache_bases = {
      vim.fn.expand("~/.cache/buf/v3/modules/b5"),
      vim.fn.expand("~/.cache/buf/v2/modules/b5"),
    }

    for _, cache in ipairs(cache_bases) do
      if vim.fn.isdirectory(cache) == 1 then
        for _, dep in ipairs(deps) do
          local dep_path = cache .. "/" .. dep
          if vim.fn.isdirectory(dep_path) == 1 then
            -- Get latest commit
            local handle = io.popen('ls -t "' .. dep_path .. '" 2>/dev/null | head -1')
            if handle then
              local commit = handle:read("*l")
              handle:close()
              if commit then
                local files_path = dep_path .. "/" .. commit .. "/files"
                if vim.fn.isdirectory(files_path) == 1 then
                  table.insert(paths, files_path)
                end
              end
            end
          end
        end
        break
      end
    end
  end

  return paths
end

return {
  -- Add proto filetype and treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },

  -- Configure protols LSP with dynamic buf integration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        protols = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("protols.toml", "buf.yaml", "buf.work.yaml", ".git")(fname)
          end,
        },
      },
      setup = {
        protols = function(_, opts)
          require("lspconfig").protols.setup(vim.tbl_deep_extend("force", opts, {
            before_init = function(_, config)
              local include_paths = get_buf_include_paths(config.root_dir)
              if #include_paths > 0 then
                config.init_options = config.init_options or {}
                config.init_options.include_paths = include_paths
              end
            end,
          }))
          return true
        end,
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
