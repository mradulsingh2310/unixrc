-- Parse buf.yaml to get module paths (supports v1 and v2 format)
local function parse_buf_yaml(buf_yaml_path)
  local paths = {}
  local file = io.open(buf_yaml_path, "r")
  if not file then
    return paths
  end

  local content = file:read("*a")
  file:close()

  -- v2 format: modules: - path: proto
  for path in content:gmatch("path:%s*([%w_/-]+)") do
    table.insert(paths, path)
  end

  -- If no paths found, assume root directory
  if #paths == 0 then
    table.insert(paths, ".")
  end

  return paths
end

-- Parse buf.lock to get dependencies dynamically
local function parse_buf_lock(buf_lock_path)
  local deps = {}
  local file = io.open(buf_lock_path, "r")
  if not file then
    return deps
  end

  local content = file:read("*a")
  file:close()

  -- Extract dependency names (e.g., buf.build/bufbuild/protovalidate)
  for dep in content:gmatch("name:%s*(buf%.build/[%w_/-]+)") do
    table.insert(deps, dep)
  end

  return deps
end

-- Find the latest commit directory for a buf module
local function get_latest_module_commit(mod_path)
  local handle = io.popen('ls -t "' .. mod_path .. '" 2>/dev/null | head -1')
  if handle then
    local commit = handle:read("*l")
    handle:close()
    return commit
  end
  return nil
end

-- Get all buf cache directories (supports different buf versions)
local function get_buf_cache_base()
  local possible_caches = {
    vim.fn.expand("~/.cache/buf/v3/modules/b5"),
    vim.fn.expand("~/.cache/buf/v2/modules/b5"),
    vim.fn.expand("~/Library/Caches/buf/v3/modules/b5"),
    vim.fn.expand("~/Library/Caches/buf/v2/modules/b5"),
  }
  for _, cache in ipairs(possible_caches) do
    if vim.fn.isdirectory(cache) == 1 then
      return cache
    end
  end
  return nil
end

-- Build include paths for protols from buf project
local function get_buf_include_paths(root_dir)
  local include_paths = {}

  -- Find buf.yaml upward from root_dir
  local buf_yaml = vim.fn.findfile("buf.yaml", root_dir .. ";")
  if buf_yaml == "" then
    return include_paths
  end

  local buf_dir = vim.fn.fnamemodify(buf_yaml, ":p:h")

  -- Parse buf.yaml for module paths
  local module_paths = parse_buf_yaml(buf_yaml)
  for _, rel_path in ipairs(module_paths) do
    local full_path = buf_dir .. "/" .. rel_path
    if vim.fn.isdirectory(full_path) == 1 then
      table.insert(include_paths, full_path)
    end
  end

  -- If no module paths found, add buf_dir itself
  if #include_paths == 0 then
    table.insert(include_paths, buf_dir)
  end

  -- Parse buf.lock for dependencies
  local buf_lock = buf_dir .. "/buf.lock"
  local deps = parse_buf_lock(buf_lock)

  -- Find buf cache and add dependency paths
  local buf_cache = get_buf_cache_base()
  if buf_cache and vim.fn.isdirectory(buf_cache) == 1 then
    for _, dep in ipairs(deps) do
      local mod_path = buf_cache .. "/" .. dep
      if vim.fn.isdirectory(mod_path) == 1 then
        local commit = get_latest_module_commit(mod_path)
        if commit then
          local files_path = mod_path .. "/" .. commit .. "/files"
          if vim.fn.isdirectory(files_path) == 1 then
            table.insert(include_paths, files_path)
          end
        end
      end
    end
  end

  return include_paths
end

-- Build the protols command with include paths
local function build_protols_cmd(root_dir)
  local cmd = { "protols" }
  local include_paths = get_buf_include_paths(root_dir)

  for _, path in ipairs(include_paths) do
    table.insert(cmd, "--include-paths")
    table.insert(cmd, path)
  end

  return cmd
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
    opts = function(_, opts)
      -- Ensure servers table exists
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      -- Configure protols server
      opts.servers.protols = {
        -- Root pattern to find buf.yaml
        root_dir = function(fname)
          local util = require("lspconfig.util")
          return util.root_pattern("buf.yaml", "buf.work.yaml", ".git")(fname)
        end,
      }

      -- Custom setup to inject include paths
      opts.setup.protols = function(_, server_opts)
        local lspconfig = require("lspconfig")

        lspconfig.protols.setup(vim.tbl_deep_extend("force", server_opts, {
          on_new_config = function(new_config, new_root_dir)
            new_config.cmd = build_protols_cmd(new_root_dir)
          end,
        }))

        return true
      end

      return opts
    end,
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
