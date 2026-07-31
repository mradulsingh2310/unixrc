-- sidekick.nvim - Copilot LSP "Next Edit Suggestions" + AI CLI terminal
--
-- Why this on top of copilot.lua + claudecode.nvim you already have:
--   copilot.lua      -> inline ghost text, single-spot completions
--   sidekick NES     -> multi-line refactors ANYWHERE in the file (the actual
--                       IntelliJ "AI suggests a whole change" equivalent)
--   claudecode.nvim  -> full agentic sessions, unchanged
--
-- IMPORTANT: cli.mux.backend only accepts "tmux" or "zellij" and defaults to
-- `vim.env.ZELLIJ and "zellij" or "tmux"`. herdr is NOT a supported backend and
-- tmux has been uninstalled, so mux MUST stay disabled or sidekick will shell
-- out to a binary that no longer exists. Sessions run in a Neovim terminal
-- instead; the only loss is CLI-session persistence across nvim restarts.
return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          enabled = false,
        },
      },
      nes = {
        enabled = true,
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- Apply/jump to a Next Edit Suggestion, else fall through to <Tab>
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select()
        end,
        desc = "Sidekick Select CLI",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Sidekick Send Visual Selection",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Sidekick Send File",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
