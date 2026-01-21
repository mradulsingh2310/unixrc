-- Java Runner Configuration
-- Keybindings:
--   Cmd+u: Run test for current Java file
--   Cmd+r: Run current Java file
--   Cmd+Shift+r: Run Spring application

-- ─────────────────────────────────────────
-- Project Configurations
-- ─────────────────────────────────────────
-- Add your project configurations here. Each project is keyed by its root directory.
-- When in a subdirectory, the runner will search upward for a matching project root.

local project_configs = {
  -- Zeus Backend
  ["/Users/mradulsingh/zeus_backend/zeus"] = {
    name = "ZeusApp",
    main_class = "com.dealmeridian.zeus.ZeusApp",
    vm_options = "-Dspring.profiles.active=local -Daws.profile=515966534558_AdministratorAccess",
    working_dir = "/Users/mradulsingh/zeus_backend/zeus",
    classpath_module = "zeus-assembly",
    -- Use Maven to run (recommended for Spring Boot with all dependencies)
    use_maven = true,
  },
  -- Add more projects here:
  -- ["/path/to/project"] = {
  --   name = "ProjectName",
  --   main_class = "com.example.MainClass",
  --   vm_options = "-Xmx512m",
  --   working_dir = "/path/to/project",
  --   use_maven = true,
  -- },
}

-- ─────────────────────────────────────────
-- Helper Functions
-- ─────────────────────────────────────────

-- Find the project root by looking for build files
local function find_project_root()
  local markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" }
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")

  while current_dir ~= "/" do
    for _, marker in ipairs(markers) do
      if vim.fn.filereadable(current_dir .. "/" .. marker) == 1 or vim.fn.isdirectory(current_dir .. "/" .. marker) == 1 then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end
  return nil
end

-- Get the project config for current file
local function get_project_config()
  local root = find_project_root()
  if not root then
    return nil
  end

  -- Check if we have a direct match
  if project_configs[root] then
    return project_configs[root], root
  end

  -- Check if current path is under any configured project
  for project_root, config in pairs(project_configs) do
    if root:find(project_root, 1, true) == 1 or project_root:find(root, 1, true) == 1 then
      return config, project_root
    end
  end

  return nil, root
end

-- Get the fully qualified class name from current file
local function get_class_from_file()
  local file_path = vim.fn.expand("%:p")

  -- Extract package from file content
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local package_name = nil
  for _, line in ipairs(lines) do
    local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
    if pkg then
      package_name = pkg
      break
    end
  end

  -- Get class name from filename
  local class_name = vim.fn.expand("%:t:r")

  if package_name then
    return package_name .. "." .. class_name
  end
  return class_name
end

-- Get test class name for a source file
local function get_test_class()
  local file_path = vim.fn.expand("%:p")
  local class_name = vim.fn.expand("%:t:r")

  -- If already in test file
  if file_path:match("/test/java/") then
    return get_class_from_file()
  end

  -- If in main source, find corresponding test
  if file_path:match("/main/java/") then
    -- Get package
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    local package_name = nil
    for _, line in ipairs(lines) do
      local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
      if pkg then
        package_name = pkg
        break
      end
    end

    local test_class = class_name .. "Test"
    if package_name then
      return package_name .. "." .. test_class
    end
    return test_class
  end

  return nil
end

-- Open terminal with command
local function run_in_terminal(cmd, working_dir)
  local cwd = working_dir or vim.fn.getcwd()
  -- Change to working directory and run
  local full_cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
  vim.cmd("botright split | resize 20 | terminal " .. full_cmd)
  -- Enter insert mode in terminal
  vim.cmd("startinsert")
end

-- ─────────────────────────────────────────
-- Main Functions
-- ─────────────────────────────────────────

-- Run test for current file
local function run_test()
  local filetype = vim.bo.filetype
  if filetype ~= "java" then
    vim.notify("Not a Java file", vim.log.levels.WARN)
    return
  end

  local test_class = get_test_class()
  if not test_class then
    vim.notify("Could not determine test class", vim.log.levels.ERROR)
    return
  end

  local config, project_root = get_project_config()
  local working_dir = config and config.working_dir or project_root or vim.fn.getcwd()

  -- Use Maven to run tests (use mvn if mvnw not available)
  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"
  local cmd = mvn .. " test -Dtest=" .. test_class .. " -q"
  vim.notify("Running test: " .. test_class, vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- Run current Java file directly
local function run_file()
  local filetype = vim.bo.filetype
  if filetype ~= "java" then
    vim.notify("Not a Java file", vim.log.levels.WARN)
    return
  end

  local class_name = get_class_from_file()
  if not class_name then
    vim.notify("Could not determine class name", vim.log.levels.ERROR)
    return
  end

  local config, project_root = get_project_config()
  local working_dir = config and config.working_dir or project_root or vim.fn.getcwd()

  -- Use Maven exec plugin to run the class
  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"
  local vm_opts = ""
  if config and config.vm_options then
    vm_opts = " -Dexec.args=\"" .. config.vm_options .. "\""
  end

  local cmd = mvn .. " compile exec:java -Dexec.mainClass=" .. class_name .. vm_opts .. " -q"
  vim.notify("Running: " .. class_name, vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- Run Spring application
local function run_app()
  local config, project_root = get_project_config()

  if not config then
    vim.notify("No project configuration found. Add your project to java-runner.lua", vim.log.levels.ERROR)
    return
  end

  local working_dir = config.working_dir or project_root

  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"
  local cmd
  if config.use_maven then
    -- Use Spring Boot Maven plugin
    local module_flag = ""
    if config.classpath_module then
      module_flag = " -pl " .. config.classpath_module
    end
    local vm_opts = ""
    if config.vm_options then
      -- Convert VM options to spring-boot.run.jvmArguments format
      vm_opts = " -Dspring-boot.run.jvmArguments=\"" .. config.vm_options .. "\""
    end
    cmd = mvn .. module_flag .. " spring-boot:run" .. vm_opts
  else
    -- Direct Java execution (requires classpath setup)
    local vm_opts = config.vm_options or ""
    cmd = "java " .. vm_opts .. " -cp target/classes " .. config.main_class
  end

  vim.notify("Starting: " .. config.name, vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- ─────────────────────────────────────────
-- Plugin Setup
-- ─────────────────────────────────────────

return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          -- Cmd+u = Run test
          vim.keymap.set({ "n", "i" }, "\x1b[27;6;117~", function()
            vim.cmd("stopinsert")
            run_test()
          end, { desc = "Java: Run test" })

          -- Cmd+r = Run current file
          vim.keymap.set({ "n", "i" }, "\x1b[27;6;114~", function()
            vim.cmd("stopinsert")
            run_file()
          end, { desc = "Java: Run file" })

          -- Cmd+Shift+r = Run Spring app
          vim.keymap.set({ "n", "i" }, "\x1b[27;6;82~", function()
            vim.cmd("stopinsert")
            run_app()
          end, { desc = "Java: Run app" })
        end,
      })
      return opts
    end,
  },
}
