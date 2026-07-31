# unixrc

My terminal development environment configuration for macOS.

**Stack:** Ghostty + herdr + Neovim (LazyVim)

**Theme:** Catppuccin Mocha with transparent backgrounds

> Migrated from tmux to [herdr](https://herdr.dev/) on 2026-08-01.
> herdr is an agent-aware multiplexer: same panes/tabs/sessions/detach model,
> plus a sidebar showing AI agent state (idle / working / blocked / done).
> The old tmux config remains in git history.

---

## Installation

### Prerequisites
- [Ghostty](https://ghostty.org/) terminal emulator
- [herdr](https://herdr.dev/) multiplexer (`brew install herdr`)
- [Neovim](https://neovim.io/) 0.11+
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

### Setup

```bash
# Clone the repo
git clone https://github.com/mradulsingh2310/unixrc.git ~/unixrc

# Symlink configs
ln -sf ~/unixrc/ghostty/config ~/.config/ghostty/config
ln -sf ~/unixrc/nvim ~/.config/nvim
mkdir -p ~/.config/herdr
ln -sf ~/unixrc/herdr/config.toml ~/.config/herdr/config.toml

# Verify the herdr config parses
herdr config check
```

---

## Keybindings Reference

### Legend
| Symbol | Key |
|--------|-----|
| `⌘` | Cmd (Super) |
| `⌥` | Option (Alt) |
| `⌃` | Ctrl |
| `⇧` | Shift |
| `prefix` | Ctrl+a (herdr prefix) |

---

## Ghostty Keybindings

Ghostty auto-starts herdr and translates macOS keybindings to terminal sequences.
Each `⌘` binding below sends the herdr prefix (`Ctrl+a`, `\x01`) plus an action key.

### Window/Pane Management

| Keybinding | Action |
|------------|--------|
| `⌘ + t` | New herdr tab |
| `⌘ + ⇧ + t` | New Ghostty window (separate terminal) |
| `⌘ + w` | Close herdr pane |
| `⌘ + d` | Vertical split |
| `⌘ + ⇧ + d` | Horizontal split |
| `⌘ + f` | Toggle fullscreen |
| `⌘ + =` | Increase font size |
| `⌘ + -` | Decrease font size |
| `⌘ + r` | Enter resize mode (then arrows, `Esc` to exit) |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `⌘ + 1-9` | Switch to herdr tab 1-9 |
| `⌥ + 1-9` | Switch to herdr tab 1-9 (no prefix) |
| `⌘ + ⇧ + ]` | Next herdr tab |
| `⌘ + ⇧ + [` | Previous herdr tab |

### Removed in the tmux → herdr migration

| Was | Why |
|-----|-----|
| `⌘ + 0` (tiled layout) | herdr has no `select-layout` equivalent |
| `⌘ + ⌥ + arrows` (resize) | herdr resize is modal — use `⌘ + r`, then arrows |
| `⌘ + =` (zoom) | was already dead: it was bound twice and font-size won. Zoom is `prefix + z` |

### Neovim Commands (via escape sequences)

| Keybinding | Action |
|------------|--------|
| `⌘ + s` | Save file |
| `⌘ + z` | Undo |
| `⌘ + ⇧ + z` | Redo |
| `⌘ + /` | Toggle comment |
| `⌘ + p` | Find files (Telescope) |
| `⌘ + ⇧ + p` | Command palette |
| `⌘ + b` | Toggle file explorer (Neo-tree) |
| `⌘ + n` | New buffer |
| `⌘ + o` | Open file |
| `⌘ + ,` | Open config |
| `⌘ + h/j/k/l` | Navigate panes |

---

## herdr Keybindings

**Prefix:** `Ctrl + a` (set in `herdr/config.toml` → `[keys] prefix`)

Most of these are herdr's own defaults — they happened to match the old tmux
binds, so only `split_vertical` needed retargeting (`|` → `v`).

### Tab/Pane Management

| Keybinding | Action | vs tmux |
|------------|--------|---------|
| `prefix + c` | New tab (inherits cwd) | same |
| `prefix + v` | Vertical split | **was `\|`** |
| `prefix + -` | Horizontal split | same |
| `prefix + x` | Close pane | same |
| `prefix + z` | Zoom/unzoom pane | same |
| `prefix + q` | Detach | was `prefix + d` |
| `prefix + ⇧ + r` | Reload config | was `prefix + r` |
| `prefix + b` | Toggle agent sidebar | **new** |
| `prefix + ?` | Show all active bindings | **new** |
| `prefix + g` | lazygit popup | **new** |

### Pane Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `prefix + h` | Focus pane left |
| `prefix + j` | Focus pane down |
| `prefix + k` | Focus pane up |
| `prefix + l` | Focus pane right |

### Tab Switching

| Keybinding | Action |
|------------|--------|
| `⌥ + 1-9` | Switch to tab 1-9, no prefix (was `⌥ + 1-5`) |
| `prefix + 1-9` | Switch to tab 1-9 |
| `prefix + n` | Next tab |
| `prefix + p` | Previous tab |

### Pane Resize

herdr's resize is **modal**, unlike tmux's one-shot `Ctrl + arrow`:

| Keybinding | Action |
|------------|--------|
| `prefix + r` (or `⌘ + r`) | Enter resize mode |
| `← ↓ ↑ →` | Resize while in resize mode |
| `Esc` | Exit resize mode |

### Copy Mode

| Keybinding | Action |
|------------|--------|
| Mouse drag | Select and copy to clipboard (`copy_on_select = true`) |

### Not carried over from tmux

- **TPM / tmux-sensible / catppuccin plugin** — herdr has no plugin system; theming is native (`[theme] name = "catppuccin"`).
- **vim-tmux-navigator** — removed from Neovim too; prefix-less `⌃+h/j/k/l` cross-navigation between multiplexer panes and Neovim splits is gone.
- **Status bar clock, date, and `pane_current_path`** — no herdr equivalent. The path now lives in the zsh prompt (see `.zshrc`); the git branch is in herdr's sidebar.

---

## Neovim Keybindings (LazyVim)

Based on [LazyVim](https://www.lazyvim.org/) with custom extensions.

### General

| Keybinding | Action |
|------------|--------|
| `<Space>` | Leader key |
| `<leader>ua` | Toggle auto-save |
| `⌃ + p` | Find files (Telescope) |

### File Navigation

| Keybinding | Action |
|------------|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `⌃ + h` | Navigate left (Neovim splits only) |
| `⌃ + j` | Navigate down |
| `⌃ + k` | Navigate up |
| `⌃ + l` | Navigate right |

### Window Resize

| Keybinding | Action |
|------------|--------|
| `⌃ + ↑` | Increase window height |
| `⌃ + ↓` | Decrease window height |
| `⌃ + ←` | Decrease window width |
| `⌃ + →` | Increase window width |

### Editing (Insert Mode - Mac-style)

| Keybinding | Action |
|------------|--------|
| `⌥ + Backspace` | Delete word backwards |
| `⌥ + Delete` | Delete word forwards |
| `⌥ + ←/→` | Move by word |
| `⌘ + ←/→` | Move to beginning/end of line |

### Quickfix

| Keybinding | Action |
|------------|--------|
| `]q` | Next quickfix |
| `[q` | Previous quickfix |
| `<leader>qo` | Open quickfix |
| `<leader>qc` | Close quickfix |
| `<leader>qx` | Clear quickfix |
| `dd` (in quickfix) | Delete entry |

### LSP (Space + l)

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |

### Git (Space + g)

| Keybinding | Action |
|------------|--------|
| `<leader>gg` | Lazygit |
| `<leader>gf` | Git files |
| `<leader>gc` | Git commits |
| `<leader>gb` | Git blame |
| `]h` | Next hunk |
| `[h` | Previous hunk |

### Java (Space + J)

| Keybinding | Command | Action |
|------------|---------|--------|
| `<leader>Jc` | `:JavaConfig` | Open run configuration (IntelliJ-style) |
| `<leader>Jt` | `:JavaTest` | Run test for current file |
| `<leader>Jr` | `:JavaRun` | Run current Java file |
| `<leader>Ja` | `:JavaApp` | Run Spring Boot application |

The Java runner stores per-project configurations in `.java-runner.json` at the project root.

### Buffers (Space + b)

| Keybinding | Action |
|------------|--------|
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Delete other buffers |
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |

### Which-Key

Press `<Space>` and wait to see all available keybindings.

---

## Installed Neovim Plugins

### Core
- **LazyVim** - Neovim distribution
- **lazy.nvim** - Plugin manager

### UI
- **catppuccin** - Color scheme (Mocha, transparent)
- **neo-tree.nvim** - File explorer
- **which-key.nvim** - Keybinding hints

### Editor
- **auto-save.nvim** - Automatic file saving
- **telescope.nvim** - Fuzzy finder
- **sidekick.nvim** - Copilot LSP Next Edit Suggestions + AI CLI terminal

### LSP
- **nvim-lspconfig** - LSP configuration
- **nvim-jdtls** - Java LSP with enhanced completion
- **nvim-cmp** - Completion engine

### Languages
- Java (jdtls with Spotless formatting)
- Protocol Buffers (protols)

---

## Auto-Sync

Config changes are **automatically synced to GitHub** using macOS `launchd`.

### How it works
- `launchd` watches your config files for changes
- When a file changes, `sync.sh` copies it to `~/unixrc`
- Changes are auto-committed and pushed to GitHub
- 10-second throttle prevents rapid-fire triggers

### Watched paths
- `~/.config/ghostty/config`
- `~/.config/herdr/config.toml`
- `~/.config/nvim/init.lua`
- `~/.config/nvim/lua/config/*`
- `~/.config/nvim/lua/plugins/*`

### Managing the sync agent

```bash
# Check status
launchctl list | grep unixrc

# Stop auto-sync
launchctl unload ~/Library/LaunchAgents/com.mradulsingh.unixrc-sync.plist

# Start auto-sync
launchctl load ~/Library/LaunchAgents/com.mradulsingh.unixrc-sync.plist

# View sync log
tail -f ~/unixrc/.sync.log

# Manual sync (if needed)
~/unixrc/sync.sh
```

### Modifying the sync behavior

All sync files are in the repo:
- `sync.sh` - The sync logic
- `com.mradulsingh.unixrc-sync.plist` - launchd configuration

After editing either file, reinstall the agent:
```bash
~/unixrc/install-sync.sh
```

### GPG Signing

Auto-sync commits are GPG signed using a **passwordless key** (required for launchd automation).

To generate a new passwordless GPG key:
```bash
# Create key config
cat > /tmp/gpg-key.txt << 'EOF'
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: Your Name (autosync)
Name-Email: your-email@example.com
Expire-Date: 0
%commit
EOF

# Generate key
gpg --batch --generate-key /tmp/gpg-key.txt

# Get key ID
gpg --list-keys --keyid-format SHORT your-email@example.com

# Export and add to GitHub (https://github.com/settings/keys)
gpg --armor --export YOUR_KEY_ID

# Configure repo to use the key
cd ~/unixrc
git config user.signingkey YOUR_KEY_ID
git config commit.gpgsign true
```

---

## Configuration Files

```
unixrc/
├── ghostty/
│   └── config          # Ghostty terminal config
├── nvim/
│   ├── init.lua        # Entry point
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua   # Auto commands
│       │   ├── keymaps.lua    # Custom keybindings
│       │   ├── lazy.lua       # Plugin manager setup
│       │   └── options.lua    # Vim options
│       └── plugins/
│           ├── autosave.lua
│           ├── colorscheme.lua
│           ├── dashboard.lua
│           ├── java.lua          # Java LSP config
│           ├── java-runner.lua   # Java run configurations
│           ├── noice.lua
│           ├── proto.lua
│           ├── search.lua
│           ├── sidekick.lua      # Copilot NES + AI CLI
│           ├── typescript.lua    # vtsls tuning
│           └── which-key.lua
├── herdr/
│   └── config.toml     # herdr multiplexer configuration
├── sync.sh             # Auto-sync script (triggered by launchd)
├── install-sync.sh     # Reinstall launchd agent after changes
└── com.mradulsingh.unixrc-sync.plist  # launchd configuration
```

---

## Features

### Navigation
`Ctrl + h/j/k/l` moves between Neovim splits. Moving between **herdr** panes uses
`prefix + h/j/k/l` — the prefix-less cross-boundary navigation that
vim-tmux-navigator provided has no herdr equivalent.

### macOS-Native Keybindings
Use familiar `Cmd + s`, `Cmd + z`, `Cmd + p` shortcuts in Neovim through Ghostty's escape sequence translation.

### Auto-Save
Files are automatically saved on:
- Leaving insert mode
- Text changes (with 1s debounce)
- Leaving buffer or focus

### Java Development
- **Java Runner** - IntelliJ-style run configurations (`<leader>J`)
  - Auto-detects JDKs, main classes, Maven modules
  - Per-project config stored in `.java-runner.json`
  - Run tests, files, or Spring Boot apps
- Spotless auto-formatting on save
- Enhanced import organization
- Static member favorites for testing frameworks

---

## License

MIT
