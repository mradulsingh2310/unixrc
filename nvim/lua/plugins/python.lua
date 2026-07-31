-- Python Development Configuration
-- basedpyright (types/navigation/inlay hints) + Ruff (lint/format) + venv detection
--
-- Migrated 2026-08-01 from Astral `ty` -> basedpyright.
-- `ty` is fast but pre-1.0 with deliberately incomplete inference, which cost
-- go-to-definition into site-packages and reliable call hierarchy.
-- LSP selection itself is set in lua/config/options.lua:
--   vim.g.lazyvim_python_lsp = "basedpyright"

-- Find project venv
local function find_venv()
  local cwd = vim.fn.getcwd()
  local venv_names = { ".venv", "venv", ".env", "env" }

  for _, name in ipairs(venv_names) do
    local python = cwd .. "/" .. name .. "/bin/python"
    if vim.fn.filereadable(python) == 1 then
      return { path = cwd .. "/" .. name, python = python }
    end
  end

  -- Check VIRTUAL_ENV env var
  local env_venv = vim.env.VIRTUAL_ENV
  if env_venv and vim.fn.isdirectory(env_venv) == 1 then
    return { path = env_venv, python = env_venv .. "/bin/python" }
  end

  return nil
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local venv = find_venv()
      opts.servers = opts.servers or {}

      -- Explicitly off. nvim-lspconfig now ships a `ty` config and
      -- mason-lspconfig auto-enables any installed server, so simply removing
      -- our old manual registration was NOT enough - ty kept attaching
      -- alongside basedpyright and double-reported diagnostics.
      opts.servers.ty = { enabled = false }
      opts.servers.pyright = { enabled = false }

      -- ── basedpyright ────────────────────────────────────────────
      opts.servers.basedpyright = vim.tbl_deep_extend("force", opts.servers.basedpyright or {}, {
        settings = {
          basedpyright = {
            -- basedpyright defaults to "recommended", which is extremely noisy
            -- on existing codebases. "standard" matches pyright's behaviour.
            -- Bump to "strict" per-project via pyrightconfig.json instead.
            analysis = {
              typeCheckingMode = "standard",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              autoImportCompletions = true,
              diagnosticMode = "openFilesOnly",
              inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
                functionReturnTypes = true,
                genericTypes = false,
              },
            },
          },
          -- Point basedpyright at the project interpreter so imports from
          -- site-packages resolve instead of showing as unresolved.
          python = venv and { pythonPath = venv.python } or {},
        },
      })

      -- ── ruff ────────────────────────────────────────────────────
      opts.servers.ruff = vim.tbl_deep_extend("force", opts.servers.ruff or {}, {
        init_options = {
          settings = {
            lineLength = 100,
            interpreter = venv and { venv.python } or nil,
          },
        },
      })

      return opts
    end,
  },

  -- Ruff is a linter, not a type checker - let basedpyright own hover and
  -- definitions so the two don't produce duplicate/conflicting responses.
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.definitionProvider = false
          end
        end,
        desc = "Disable ruff hover/definition in favour of basedpyright",
      })
    end,
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
