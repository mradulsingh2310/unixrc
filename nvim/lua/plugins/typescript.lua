-- TypeScript / JavaScript - IntelliJ-grade augmentation over LazyVim's
-- lang.typescript extra (which supplies vtsls; see lua/config/options.lua for
-- vim.g.lazyvim_ts_lsp = "vtsls").
--
-- vtsls is chosen over ts_ls/typescript-tools because it resolves the correct
-- per-package tsconfig.json in monorepos automatically. Never enable vtsls and
-- ts_ls together - they will both attach and double-report diagnostics.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            -- Raise the tsserver heap. The 3GB default OOMs on large monorepos
            -- and silently degrades to "no completions" rather than erroring.
            vtsls = {
              tsserver = {
                globalPlugins = {},
                maxTsServerMemory = 8192,
              },
              experimental = {
                -- Resolve the full completion item (incl. auto-import edits)
                -- before inserting.
                completion = { enableServerSideFuzzyMatch = true },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = { completeFunctionCalls = true },
              preferences = {
                importModuleSpecifier = "shortest",
                preferTypeOnlyAutoImports = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = { completeFunctionCalls = true },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
