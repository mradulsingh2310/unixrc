-- Java LSP configuration with auto-import support and proper project indexing
return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          -- Enable autobuild for better indexing
          autobuild = { enabled = true },

          -- Project import settings for Maven/Gradle
          import = {
            enabled = true,
            maven = { enabled = true },
            gradle = { enabled = true },
            exclusions = {
              "**/node_modules/**",
              "**/.metadata/**",
              "**/archetype-resources/**",
              "**/META-INF/maven/**",
            },
          },

          -- Maven specific settings
          maven = {
            downloadSources = true,
            updateSnapshots = true,
          },

          -- Completion settings
          completion = {
            -- Show unimported classes in completion
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.jupiter.api.Assertions.*",
              "org.mockito.Mockito.*",
              "org.mockito.ArgumentMatchers.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
            importOrder = {
              "java",
              "javax",
              "jakarta",
              "com",
              "org",
            },
            -- Improve completion matching
            matchCase = "firstLetter",
          },

          -- Source organization
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },

          -- Eclipse settings for better indexing
          eclipse = {
            downloadSources = true,
          },

          -- Reference code lens
          referencesCodeLens = { enabled = true },
          implementationsCodeLens = { enabled = true },

          -- Signature help
          signatureHelp = { enabled = true },
        },
      })
      return opts
    end,
  },

  -- ── Java auto-import on completion ──────────────────────────────
  -- This block previously targeted "hrsh7th/nvim-cmp", which is NOT installed
  -- (LazyVim moved to blink.cmp). lazy.nvim silently ignores specs for absent
  -- plugins, so the auto-import fix never ran. Rewritten for blink.cmp.
  --
  -- jdtls sends `import` statements as `additionalTextEdits` on the completion
  -- item's *resolve* response, not the initial response. Two things are needed:
  --   1. jdtls must be told the client can apply them  -> extendedClientCapabilities
  --   2. the completion UI must await resolve before confirming -> blink.cmp
  -- See https://github.com/Saghen/blink.cmp/issues/1491
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.init_options = opts.init_options or {}
      opts.init_options.extendedClientCapabilities = vim.tbl_deep_extend(
        "force",
        opts.init_options.extendedClientCapabilities or {},
        {
          -- THE fix: lets jdtls send imports as additionalTextEdits on resolve.
          resolveAdditionalTextEditsSupport = true,
          classFileContentsSupport = true,
          generateToStringPromptSupport = true,
          hashCodeEqualsPromptSupport = true,
          advancedExtractRefactoringSupport = true,
          advancedOrganizeImportsSupport = true,
existing  = nil,
        }
      )
      return opts
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- Give jdtls time to return additionalTextEdits before confirm applies
        -- the item. Without this, confirming quickly drops the import.
        accept = { auto_brackets = { enabled = true } },
        menu = { draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
    },
  },
}
