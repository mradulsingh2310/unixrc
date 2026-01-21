-- Python Development Configuration
-- Ruff (native LSP) + venv detection

-- Utility: Find Python virtual environment
local function find_venv()
  local cwd = vim.fn.getcwd()

  -- Common venv directory names to check
  local venv_names = { ".venv", "venv", ".env", "env" }

  for _, name in ipairs(venv_names) do
    local venv_path = cwd .. "/" .. name
    if vim.fn.isdirectory(venv_path) == 1 then
      local python_path = venv_path .. "/bin/python"
      if vim.fn.filereadable(python_path) == 1 then
        return {
          path = venv_path,
          python = python_path,
        }
      end
    end
  end

  -- Check VIRTUAL_ENV environment variable
  local env_venv = vim.env.VIRTUAL_ENV
  if env_venv and vim.fn.isdirectory(env_venv) == 1 then
    return {
      path = env_venv,
      python = env_venv .. "/bin/python",
    }
  end

  return nil
end

return {
  -- Configure LSP servers for Python
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Ruff native language server (replaces ruff-lsp)
        ruff = {
          init_options = {
            settings = {
              lineLength = 100,
            },
          },
        },

        -- Configure basedpyright with venv support
        basedpyright = {
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- Let Ruff handle imports
            },
            python = {
              analysis = {
                typeCheckingMode = "basic",
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
      },
    },
  },

  -- Auto-detect venv and configure LSP on attach
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Set up an autocmd to configure venv when LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          -- Disable Ruff hover (let basedpyright handle it)
          if client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end
        end,
      })
      return opts
    end,
  },

  -- Mason - ensure tools are installed
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ruff",
      },
    },
  },

  -- Conform for formatting (uses Ruff)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
