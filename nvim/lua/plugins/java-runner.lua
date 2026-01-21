-- Java Runner Configuration
-- Keybindings (all under <leader>J for Java):
--   <leader>Jc: Open run configuration editor
--   <leader>Jt: Run test for current Java file
--   <leader>Jr: Run current Java file
--   <leader>Ja: Run Spring application
-- Commands: :JavaConfig, :JavaTest, :JavaRun, :JavaApp

local M = {}

-- ─────────────────────────────────────────
-- Configuration Storage
-- ─────────────────────────────────────────
-- Configs are stored per-project in .java-runner.json

local function get_config_file_path(project_root)
  return project_root .. "/.java-runner.json"
end

local function load_project_config(project_root)
  local config_path = get_config_file_path(project_root)
  local file = io.open(config_path, "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  local ok, config = pcall(vim.json.decode, content)
  if ok then
    return config
  end
  return nil
end

local function save_project_config(project_root, config)
  local config_path = get_config_file_path(project_root)
  local file = io.open(config_path, "w")
  if not file then
    vim.notify("Failed to save config to " .. config_path, vim.log.levels.ERROR)
    return false
  end
  local ok, json = pcall(vim.json.encode, config)
  if ok then
    file:write(json)
    file:close()
    vim.notify("Configuration saved", vim.log.levels.INFO)
    return true
  end
  file:close()
  return false
end

-- ─────────────────────────────────────────
-- JDK Detection
-- ─────────────────────────────────────────

local function detect_installed_jdks()
  local jdks = {}

  -- macOS: Check JavaVirtualMachines directory
  local jvm_dir = "/Library/Java/JavaVirtualMachines"
  local handle = io.popen("ls -1 " .. jvm_dir .. " 2>/dev/null")
  if handle then
    for line in handle:lines() do
      local version = line:match("jdk%-(%d+)") or line:match("openjdk%-(%d+)") or line:match("temurin%-(%d+)")
      if version then
        local java_home = jvm_dir .. "/" .. line .. "/Contents/Home"
        table.insert(jdks, {
          name = line,
          version = version,
          path = java_home,
        })
      end
    end
    handle:close()
  end

  -- Also check SDKMAN if available
  local sdkman_dir = os.getenv("HOME") .. "/.sdkman/candidates/java"
  handle = io.popen("ls -1 " .. sdkman_dir .. " 2>/dev/null")
  if handle then
    for line in handle:lines() do
      if line ~= "current" then
        local version = line:match("(%d+)") or "?"
        table.insert(jdks, {
          name = "SDKMAN: " .. line,
          version = version,
          path = sdkman_dir .. "/" .. line,
        })
      end
    end
    handle:close()
  end

  -- Sort by version (newest first)
  table.sort(jdks, function(a, b)
    return tonumber(a.version) > tonumber(b.version)
  end)

  return jdks
end

-- ─────────────────────────────────────────
-- Project Detection
-- ─────────────────────────────────────────

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
  return vim.fn.getcwd()
end

local function detect_maven_modules(project_root)
  local modules = {}
  local handle = io.popen("find " .. vim.fn.shellescape(project_root) .. " -maxdepth 2 -name 'pom.xml' -type f 2>/dev/null")
  if handle then
    for line in handle:lines() do
      local module_dir = vim.fn.fnamemodify(line, ":h")
      local module_name = vim.fn.fnamemodify(module_dir, ":t")
      if module_dir ~= project_root then
        table.insert(modules, module_name)
      end
    end
    handle:close()
  end
  table.sort(modules)
  return modules
end

-- ─────────────────────────────────────────
-- Main Class Discovery
-- ─────────────────────────────────────────

local function find_main_classes(project_root)
  local main_classes = {}

  -- Search for classes with main method
  local cmd = "grep -r --include='*.java' 'public static void main' " .. vim.fn.shellescape(project_root) .. " 2>/dev/null | head -50"
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      local file_path = line:match("^([^:]+):")
      if file_path then
        -- Extract package and class name
        local file = io.open(file_path, "r")
        if file then
          local content = file:read("*all")
          file:close()

          local package_name = content:match("package%s+([%w%.]+)%s*;")
          local class_name = vim.fn.fnamemodify(file_path, ":t:r")

          local fqcn = class_name
          if package_name then
            fqcn = package_name .. "." .. class_name
          end

          -- Detect module from path
          local relative = file_path:gsub(project_root .. "/", "")
          local module = relative:match("^([^/]+)/src/")

          table.insert(main_classes, {
            class = fqcn,
            file = file_path,
            module = module,
          })
        end
      end
    end
    handle:close()
  end

  return main_classes
end

-- ─────────────────────────────────────────
-- Package Detection
-- ─────────────────────────────────────────

local function detect_base_packages(project_root)
  local packages = {}
  local seen = {}

  local cmd = "grep -rh --include='*.java' '^package ' " .. vim.fn.shellescape(project_root) .. " 2>/dev/null | head -100"
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      local pkg = line:match("package%s+([%w%.]+)%s*;")
      if pkg then
        -- Get base package (first 2-3 segments)
        local parts = {}
        for part in pkg:gmatch("[^%.]+") do
          table.insert(parts, part)
          if #parts >= 3 then break end
        end
        local base_pkg = table.concat(parts, ".")
        if not seen[base_pkg] then
          seen[base_pkg] = true
          table.insert(packages, base_pkg)
        end
      end
    end
    handle:close()
  end

  table.sort(packages)
  return packages
end

-- ─────────────────────────────────────────
-- Configuration UI
-- ─────────────────────────────────────────

local function show_config_ui()
  local project_root = find_project_root()
  local config = load_project_config(project_root) or {
    name = vim.fn.fnamemodify(project_root, ":t"),
    main_class = "",
    module = "",
    java_home = "",
    vm_options = "",
    working_dir = project_root,
    env_file = "",
    env_vars = {},
    base_package = "",
  }

  local function refresh_menu()
    local menu_items = {
      { key = "n", label = "Name", value = config.name or "" },
      { key = "m", label = "Main Class", value = config.main_class or "" },
      { key = "M", label = "Module", value = config.module or "" },
      { key = "j", label = "Java Home", value = config.java_home or "(system default)" },
      { key = "v", label = "VM Options", value = config.vm_options or "" },
      { key = "w", label = "Working Dir", value = config.working_dir or project_root },
      { key = "e", label = "Env File", value = config.env_file or "" },
      { key = "E", label = "Env Variables", value = vim.inspect(config.env_vars or {}) },
      { key = "p", label = "Base Package", value = config.base_package or "(auto-detect)" },
      { key = "s", label = "── Save Configuration ──", value = "" },
      { key = "q", label = "── Cancel ──", value = "" },
    }

    local lines = { "╭─────────────────────────────────────────────────────────╮" }
    table.insert(lines, "│           Java Run Configuration                        │")
    table.insert(lines, "│           Project: " .. string.format("%-37s", vim.fn.fnamemodify(project_root, ":t")) .. " │")
    table.insert(lines, "╰─────────────────────────────────────────────────────────╯")
    table.insert(lines, "")

    for _, item in ipairs(menu_items) do
      if item.key == "s" or item.key == "q" then
        table.insert(lines, string.format("  [%s] %s", item.key, item.label))
      else
        local display_val = item.value
        if #display_val > 40 then
          display_val = "..." .. display_val:sub(-37)
        end
        table.insert(lines, string.format("  [%s] %-15s: %s", item.key, item.label, display_val))
      end
    end

    return lines, menu_items
  end

  local function show_menu()
    local lines, menu_items = refresh_menu()

    -- Create floating window
    local width = 60
    local height = #lines + 2
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    local win_opts = {
      relative = "editor",
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = "minimal",
      border = "rounded",
    }

    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.api.nvim_win_set_option(win, "cursorline", true)

    -- Key handlers
    local function close_win()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end

    local function handle_key(key)
      close_win()

      if key == "q" then
        return
      elseif key == "s" then
        save_project_config(project_root, config)
        return
      elseif key == "n" then
        vim.ui.input({ prompt = "Configuration Name: ", default = config.name }, function(input)
          if input then
            config.name = input
            vim.schedule(show_menu)
          end
        end)
      elseif key == "m" then
        -- Show main class picker
        local main_classes = find_main_classes(project_root)
        if #main_classes > 0 then
          local choices = {}
          for _, mc in ipairs(main_classes) do
            local label = mc.class
            if mc.module then
              label = label .. " [" .. mc.module .. "]"
            end
            table.insert(choices, label)
          end
          table.insert(choices, "── Enter manually ──")

          vim.ui.select(choices, { prompt = "Select Main Class:" }, function(choice, idx)
            if choice == "── Enter manually ──" then
              vim.ui.input({ prompt = "Main Class: ", default = config.main_class }, function(input)
                if input then
                  config.main_class = input
                  vim.schedule(show_menu)
                end
              end)
            elseif idx and main_classes[idx] then
              config.main_class = main_classes[idx].class
              if main_classes[idx].module and (not config.module or config.module == "") then
                config.module = main_classes[idx].module
              end
              vim.schedule(show_menu)
            end
          end)
        else
          vim.ui.input({ prompt = "Main Class: ", default = config.main_class }, function(input)
            if input then
              config.main_class = input
              vim.schedule(show_menu)
            end
          end)
        end
      elseif key == "M" then
        -- Show module picker
        local modules = detect_maven_modules(project_root)
        if #modules > 0 then
          table.insert(modules, 1, "(none - root project)")
          vim.ui.select(modules, { prompt = "Select Module:" }, function(choice)
            if choice == "(none - root project)" then
              config.module = ""
            elseif choice then
              config.module = choice
            end
            vim.schedule(show_menu)
          end)
        else
          vim.notify("No Maven modules found", vim.log.levels.INFO)
          vim.schedule(show_menu)
        end
      elseif key == "j" then
        -- Show JDK picker
        local jdks = detect_installed_jdks()
        local choices = { "(system default)" }
        for _, jdk in ipairs(jdks) do
          table.insert(choices, string.format("Java %s (%s)", jdk.version, jdk.name))
        end

        vim.ui.select(choices, { prompt = "Select JDK:" }, function(choice, idx)
          if idx == 1 then
            config.java_home = ""
          elseif idx and jdks[idx - 1] then
            config.java_home = jdks[idx - 1].path
          end
          vim.schedule(show_menu)
        end)
      elseif key == "v" then
        vim.ui.input({ prompt = "VM Options: ", default = config.vm_options }, function(input)
          if input then
            config.vm_options = input
            vim.schedule(show_menu)
          end
        end)
      elseif key == "w" then
        vim.ui.input({ prompt = "Working Directory: ", default = config.working_dir }, function(input)
          if input then
            config.working_dir = input
            vim.schedule(show_menu)
          end
        end)
      elseif key == "e" then
        vim.ui.input({ prompt = "Env File (.env path): ", default = config.env_file }, function(input)
          if input then
            config.env_file = input
            vim.schedule(show_menu)
          end
        end)
      elseif key == "E" then
        vim.ui.input({ prompt = "Env Variables (KEY=val;KEY2=val2): ", default = "" }, function(input)
          if input and input ~= "" then
            config.env_vars = config.env_vars or {}
            for pair in input:gmatch("[^;]+") do
              local k, v = pair:match("([^=]+)=(.+)")
              if k and v then
                config.env_vars[k] = v
              end
            end
            vim.schedule(show_menu)
          else
            vim.schedule(show_menu)
          end
        end)
      elseif key == "p" then
        -- Show package picker
        local packages = detect_base_packages(project_root)
        if #packages > 0 then
          table.insert(packages, 1, "(auto-detect)")
          table.insert(packages, "── Enter manually ──")

          vim.ui.select(packages, { prompt = "Select Base Package:" }, function(choice)
            if choice == "(auto-detect)" then
              config.base_package = ""
            elseif choice == "── Enter manually ──" then
              vim.ui.input({ prompt = "Base Package: ", default = config.base_package }, function(input)
                if input then
                  config.base_package = input
                  vim.schedule(show_menu)
                end
              end)
            elseif choice then
              config.base_package = choice
              vim.schedule(show_menu)
            end
          end)
        else
          vim.ui.input({ prompt = "Base Package: ", default = config.base_package }, function(input)
            if input then
              config.base_package = input
              vim.schedule(show_menu)
            end
          end)
        end
      end
    end

    -- Set up keymaps
    local keys = { "n", "m", "M", "j", "v", "w", "e", "E", "p", "s", "q" }
    for _, key in ipairs(keys) do
      vim.keymap.set("n", key, function()
        handle_key(key)
      end, { buffer = buf, nowait = true })
    end

    -- Also close on Escape
    vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, nowait = true })
  end

  show_menu()
end

-- ─────────────────────────────────────────
-- Run Functions
-- ─────────────────────────────────────────

local function get_project_config()
  local project_root = find_project_root()
  local config = load_project_config(project_root)
  return config, project_root
end

local function build_env_prefix(config)
  local env_parts = {}

  -- Add JAVA_HOME if configured
  if config.java_home and config.java_home ~= "" then
    table.insert(env_parts, "JAVA_HOME=" .. vim.fn.shellescape(config.java_home))
    table.insert(env_parts, "PATH=" .. vim.fn.shellescape(config.java_home .. "/bin") .. ":$PATH")
  end

  -- Add env vars from config
  if config.env_vars then
    for k, v in pairs(config.env_vars) do
      table.insert(env_parts, k .. "=" .. vim.fn.shellescape(v))
    end
  end

  -- Source env file if exists
  local env_source = ""
  if config.env_file and config.env_file ~= "" then
    env_source = "set -a && source " .. vim.fn.shellescape(config.env_file) .. " && set +a && "
  end

  if #env_parts > 0 then
    return "export " .. table.concat(env_parts, " ") .. " && " .. env_source
  end
  return env_source
end

local function detect_module_from_path(file_path, working_dir)
  local relative = file_path:gsub(working_dir .. "/", "")
  local module = relative:match("^([^/]+)/src/")
  return module
end

local function get_class_from_file()
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local package_name = nil
  for _, line in ipairs(lines) do
    local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
    if pkg then
      package_name = pkg
      break
    end
  end

  local class_name = vim.fn.expand("%:t:r")
  if package_name then
    return package_name .. "." .. class_name
  end
  return class_name
end

local function get_test_class()
  local file_path = vim.fn.expand("%:p")
  local class_name = vim.fn.expand("%:t:r")

  if file_path:match("/test/java/") then
    return get_class_from_file()
  end

  if file_path:match("/main/java/") then
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

local function run_in_terminal(cmd, working_dir)
  local cwd = working_dir or vim.fn.getcwd()
  local full_cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd
  vim.cmd("botright split | resize 20 | terminal " .. full_cmd)
  vim.cmd("startinsert")
end

-- Run test for current file
local function run_test()
  if vim.bo.filetype ~= "java" then
    vim.notify("Not a Java file", vim.log.levels.WARN)
    return
  end

  local test_class = get_test_class()
  if not test_class then
    vim.notify("Could not determine test class", vim.log.levels.ERROR)
    return
  end

  local config, project_root = get_project_config()
  local working_dir = (config and config.working_dir) or project_root
  local file_path = vim.fn.expand("%:p")

  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"

  local module_flag = ""
  local module = (config and config.module) or detect_module_from_path(file_path, working_dir)
  if module and module ~= "" then
    module_flag = " -pl " .. module
  end

  local env_prefix = config and build_env_prefix(config) or ""
  local cmd = env_prefix .. mvn .. module_flag .. " test -Dtest=" .. test_class

  vim.notify("Running test: " .. test_class, vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- Run current Java file
local function run_file()
  if vim.bo.filetype ~= "java" then
    vim.notify("Not a Java file", vim.log.levels.WARN)
    return
  end

  local class_name = get_class_from_file()
  if not class_name then
    vim.notify("Could not determine class name", vim.log.levels.ERROR)
    return
  end

  local config, project_root = get_project_config()
  local working_dir = (config and config.working_dir) or project_root
  local file_path = vim.fn.expand("%:p")

  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"

  local module_flag = ""
  local module = detect_module_from_path(file_path, working_dir)
  if module and module ~= "" then
    module_flag = " -pl " .. module
  end

  local vm_opts = ""
  if config and config.vm_options and config.vm_options ~= "" then
    vm_opts = " \"-Dexec.args=" .. config.vm_options .. "\""
  end

  local env_prefix = config and build_env_prefix(config) or ""
  local cmd = env_prefix .. mvn .. module_flag .. " compile exec:java -Dexec.mainClass=" .. class_name .. vm_opts

  vim.notify("Running: " .. class_name, vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- Run Spring application
local function run_app()
  local config, project_root = get_project_config()

  if not config or not config.main_class or config.main_class == "" then
    vim.notify("No run configuration found. Press <leader>Jc to configure.", vim.log.levels.WARN)
    show_config_ui()
    return
  end

  local working_dir = config.working_dir or project_root
  local mvn = vim.fn.filereadable(working_dir .. "/mvnw") == 1 and "./mvnw" or "mvn"

  local module_flag = ""
  if config.module and config.module ~= "" then
    module_flag = " -pl " .. config.module
  end

  local vm_opts = ""
  if config.vm_options and config.vm_options ~= "" then
    vm_opts = " -Dspring-boot.run.jvmArguments=\"" .. config.vm_options .. "\""
  end

  local env_prefix = build_env_prefix(config)
  local cmd = env_prefix .. mvn .. module_flag .. " spring-boot:run" .. vm_opts

  vim.notify("Starting: " .. (config.name or config.main_class), vim.log.levels.INFO)
  run_in_terminal(cmd, working_dir)
end

-- ─────────────────────────────────────────
-- Plugin Setup
-- ─────────────────────────────────────────

-- Create commands for the functions
vim.api.nvim_create_user_command("JavaConfig", show_config_ui, { desc = "Open Java run configuration" })
vim.api.nvim_create_user_command("JavaTest", run_test, { desc = "Run Java test" })
vim.api.nvim_create_user_command("JavaRun", run_file, { desc = "Run Java file" })
vim.api.nvim_create_user_command("JavaApp", run_app, { desc = "Run Spring app" })

return {
  -- Register keymaps with which-key for discoverability
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>J", group = "Java", icon = "" },
      },
    },
  },
  -- Standalone config to set keymaps reliably
  {
    dir = vim.fn.stdpath("config") .. "/lua/plugins",
    name = "java-runner-keys",
    lazy = false,
    keys = {
      { "<leader>Jc", "<cmd>JavaConfig<cr>", desc = "Java: Config" },
      { "<leader>Jt", "<cmd>JavaTest<cr>", desc = "Java: Test" },
      { "<leader>Jr", "<cmd>JavaRun<cr>", desc = "Java: Run file" },
      { "<leader>Ja", "<cmd>JavaApp<cr>", desc = "Java: Run app" },
    },
  },
}
