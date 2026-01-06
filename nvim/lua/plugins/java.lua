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

  -- Ensure nvim-cmp resolves completion items (applies imports)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.completion = opts.completion or {}
      opts.completion.completeopt = "menu,menuone,noinsert"

      -- Ensure we confirm with replace to apply additional text edits (imports)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
        ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),
      })

      return opts
    end,
  },
}
